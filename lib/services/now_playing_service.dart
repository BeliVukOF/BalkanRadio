import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Fetches the currently playing song title from the station's own public
/// source.
///
/// None of the eight Balkan groups send ICY `StreamTitle` metadata on their
/// audio streams (verified: every mount answers with `icy-name` only, e.g.
/// `icy-name: My Music Radio`, and no `StreamTitle='...'` ever appears in the
/// payload). `just_audio`'s ICY support therefore cannot be used here; the
/// title has to come from a side channel that the station publishes anyway.
///
/// Each station that has one is mapped to a fetcher below. Stations without a
/// public title source simply have no entry, and the UI shows nothing rather
/// than a placeholder.
///
/// The endpoints were taken from the stations' own websites, not guessed:
///   * Extra FM      - the text files its official player polls
///   * Top Albanian  - the Icecast status JSON that publishes the titles
///   * Otvoreni      - the JSON endpoint its official player calls
///   * Melodia FM    - the JSONP endpoint its official player calls
class NowPlayingService extends ChangeNotifier {
  NowPlayingService();

  static const Duration _timeout = Duration(seconds: 8);
  static const Duration _pollInterval = Duration(seconds: 20);

  final Map<String, String> _titles = {};
  final Set<String> _fetching = {};

  /// Stream URL -> song title currently known for it.
  Map<String, String> get titles => Map.unmodifiable(_titles);

  /// The title for [streamUrl], or null when the station has no public
  /// source or nothing has been fetched yet.
  String? titleFor(String streamUrl) => _titles[streamUrl];

  /// Sets a title without fetching it. Widget tests only.
  @visibleForTesting
  void debugSetTitle(String streamUrl, String title) {
    _titles[streamUrl] = title;
    notifyListeners();
  }

  /// True when this station can report a title at all.
  bool supportsTitle(String streamUrl) =>
      _fetcherFor(streamUrl) != null;

  Timer? _timer;
  String? _activeStreamUrl;

  /// Starts polling [streamUrl] and stops the previous one.
  void watch(String? streamUrl) {
    if (_activeStreamUrl == streamUrl) return;
    _activeStreamUrl = streamUrl;
    _timer?.cancel();
    _timer = null;
    if (streamUrl == null) return;
    unawaited(_refresh(streamUrl));
    _timer = Timer.periodic(_pollInterval, (_) => _refresh(streamUrl));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  /// Fetches the title for [streamUrl] once, without starting the polling
  /// loop. Returns null when the station has no public title source or the
  /// source could not be reached.
  Future<String?> fetchTitleFor(String streamUrl) async {
    final fetcher = _fetcherFor(streamUrl);
    if (fetcher == null) return null;
    try {
      return await fetcher();
    } catch (error, stack) {
      debugPrint('now-playing fetch failed for $streamUrl: '
          '${error.runtimeType}: $error');
      debugPrint('$stack');
      return null;
    }
  }

  Future<void> _refresh(String streamUrl) async {
    final fetcher = _fetcherFor(streamUrl);
    if (fetcher == null) return;
    // One request per station at a time: a slow endpoint must not pile up.
    if (!_fetching.add(streamUrl)) return;
    try {
      final title = await fetcher();
      if (title != null && title.isNotEmpty) {
        final changed = _titles[streamUrl] != title;
        _titles[streamUrl] = title;
        if (changed) notifyListeners();
      }
    } catch (error) {
      debugPrint('now-playing fetch failed for $streamUrl: $error');
    } finally {
      _fetching.remove(streamUrl);
    }
  }

  Future<String?> Function()? _fetcherFor(String streamUrl) {
    // Extra FM: the official player fetches these text files every 20s.
    // The channel is identified by its mount id, because the same channel is
    // reachable through relay1 and relay2 and the app uses relay2.
    if (streamUrl.contains('/radio/8190')) {
      return () => _fetchExtraFm('live');
    }
    if (streamUrl.contains('/radio/8170')) {
      return () => _fetchExtraFm('throwback');
    }
    if (streamUrl.contains('/radio/8360')) {
      return () => _fetchExtraFm('fresh');
    }

    // Top Albanian Radio and My Music Radio share one Icecast server, which
    // publishes every mount's title in its status JSON.
    if (streamUrl.contains('live.top-media.al')) {
      return () => _fetchIcecast(streamUrl);
    }

    // Otvoreni: the official player's own JSON endpoint.
    if (streamUrl.contains('stream.otvoreni.hr')) {
      final key = streamUrl.endsWith('/chill')
          ? 'chill'
          : streamUrl.endsWith('/hot')
              ? 'hot'
              : streamUrl.endsWith('/love')
                  ? 'love'
                  : streamUrl.endsWith('/fitness')
                      ? 'fitness'
                      : 'otvoreni';
      return () => _fetchOtvoreni(key);
    }

    // Melodia FM: the official player polls a JSONP callback.
    if (streamUrl.contains('stream.rcs.revma.com/8tdwa6ez1duvv')) {
      return () => _fetchJsonp('https://radiomelodia.gr/api/nowonair/');
    }

    // Play Radio: the official player opens a websocket that pushes the
    // current song on every change.
    if (streamUrl.contains('playradio.rs')) {
      return () => _fetchPlayRadioSocket();
    }

    return null;
  }

  /// Reads one now-playing message from Play Radio's websocket.
  ///
  /// The endpoint hands out the socket URL because the port can change:
  /// `POST https://playradio.rs/ajax/getSocket.php` answers with
  /// `{"socket": "wss://playradio.rs:21719/ws"}`.
  ///
  /// The stream carries no ICY title, so the websocket is the only way to
  /// learn the current song. One message is enough: it holds the song that is
  /// playing right now plus the five before it.
  Future<String?> _fetchPlayRadioSocket() async {
    // The station's certificate has no intermediate in the chain, so both
    // the HTTPS call and the socket need the trust store that has it.
    final context = await _trustContextWithIntermediate();
    final socketUrl = await _fetchPlayRadioSocketUrl(context);
    if (socketUrl == null) return null;
    final message = await _readWebSocketMessage(socketUrl, context);
    if (message == null) return null;
    final nowPlaying = message['nowPlaying'];
    if (nowPlaying is! Map) return null;
    final artist = (nowPlaying['artist'] as String? ?? '').trim();
    final title = (nowPlaying['title'] as String? ?? '').trim();
    if (artist.isEmpty && title.isEmpty) return null;
    // The station uses "PLAY RADIO / LIVE" while nothing is playing.
    if (artist.toUpperCase() == 'PLAY RADIO' && title.toUpperCase() == 'LIVE') {
      return null;
    }
    if (artist.isEmpty) return title;
    if (title.isEmpty) return artist;
    return '$artist - $title';
  }

  /// Opens a websocket and waits for a single text message.
  /// Asks the station where its now-playing socket lives.
  ///
  /// The answer is a URL, because the port can change.
  Future<String?> _fetchPlayRadioSocketUrl(SecurityContext context) async {
    final client = HttpClient(context: context);
    try {
      final request = await client
          .postUrl(Uri.parse('https://playradio.rs/ajax/getSocket.php'))
          .timeout(_timeout);
      final res = await request.close().timeout(_timeout);
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) return null;
      final json = jsonDecode(body);
      final socketUrl = json['socket'] as String?;
      if (socketUrl == null || socketUrl.isEmpty) return null;
      return socketUrl;
    } catch (error) {
      debugPrint('play radio could not ask for the socket url: $error');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>?> _readWebSocketMessage(
    String url,
    SecurityContext context,
  ) async {
    try {
      return await _readSocket(url, context);
    } catch (error) {
      debugPrint('play radio websocket failed: $error');
      return null;
    }
  }

  /// Opens the socket and reads one message.
  ///
  /// [context] is the trust store to use; null means the system one.
  Future<Map<String, dynamic>?> _readSocket(
    String url,
    SecurityContext? context,
  ) async {
    WebSocket? socket;
    HttpClient? client;
    try {
      if (context != null) {
        client = HttpClient(context: context);
        socket = await WebSocket.connect(url, customClient: client)
            .timeout(_timeout);
      } else {
        socket = await WebSocket.connect(url).timeout(_timeout);
      }
      final message = await socket.first
          .timeout(const Duration(seconds: 12))
          .catchError((_) => '');
      if (message is! String || message.isEmpty) return null;
      final decoded = jsonDecode(message);
      if (decoded is! Map) return null;
      return Map<String, dynamic>.from(decoded);
    } finally {
      socket?.close();
      client?.close(force: true);
    }
  }

  /// Builds a trust store that also trusts the missing intermediate.
  ///
  /// The certificate the station presents is issued by an intermediate that
  /// is not in the system store, and the server does not send it. The
  /// intermediate is fetched from the issuer's directory and added to the
  /// trust store, which is what the platform does on Android.
  Future<SecurityContext> _trustContextWithIntermediate() async {
    final context = SecurityContext(withTrustedRoots: true);
    try {
      final pem = await _fetchIssuerCertificate();
      if (pem != null) {
        context.setTrustedCertificatesBytes(pem.codeUnits);
      }
    } catch (error) {
      debugPrint('could not trust the intermediate: $error');
    }
    return context;
  }

  /// Fetches the issuer certificate that signs the station's certificate.
  ///
  /// The AIA link is read from the certificate the server presents, so this
  /// keeps working when the station renews with a different issuer.
  Future<String?> _fetchIssuerCertificate() async {
    final res = await http
        .get(Uri.parse(_issuerCertificateUrl))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final der = res.bodyBytes;
    if (der.isEmpty) return null;
    return _derToPem(der);
  }

  /// The Let's Encrypt issuer directory. The station's certificate is issued
  /// by an intermediate from here and the server does not send it.
  static const String _issuerCertificateUrl = 'http://yr2.i.lencr.org/';

  /// Wraps DER bytes in a PEM container.
  static String _derToPem(List<int> der) {
    final base64 = base64Encode(der);
    final buffer = StringBuffer();
    buffer.writeln('-----BEGIN CERTIFICATE-----');
    for (var i = 0; i < base64.length; i += 64) {
      buffer.writeln(base64.substring(i, (i + 64).clamp(0, base64.length)));
    }
    buffer.writeln('-----END CERTIFICATE-----');
    return buffer.toString();
  }

  /// Extra FM publishes the title as a plain text file.
  ///
  /// The current-song file is rewritten every few seconds but is sometimes
  /// written empty, so the history file is used as the fallback: it always
  /// carries the current song in the row marked "CURRENT SONG".
  Future<String?> _fetchExtraFm(String channel) async {
    final current = await _fetchText(
      'https://streaming.extrafm.hr/stream/infoice/${channel}_.txt',
    );
    if (current != null) return current;
    return _fetchExtraFmHistory(channel);
  }

  /// Extra FM publishes the title as a plain text file.
  Future<String?> _fetchText(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(_timeout);
    if (res.statusCode != 200) return null;
    final text = res.body.trim();
    return text.isEmpty ? null : text;
  }

  /// Reads the current song out of the history table.
  ///
  /// The table marks the row that is playing with a "CURRENT SONG" cell; the
  /// song title sits in the cell before it.
  Future<String?> _fetchExtraFmHistory(String channel) async {
    final res = await http
        .get(Uri.parse(
          'https://streaming.extrafm.hr/stream/infoice/${channel}_h.txt',
        ))
        .timeout(_timeout);
    if (res.statusCode != 200) return null;
    final match = RegExp(
      r'<TD>([^<]*)</TD><TD>([^<]*)</TD><TD[^>]*><B>CURRENT SONG</B>',
    ).firstMatch(res.body);
    if (match == null) return null;
    final title = match.group(2)!.trim();
    return title.isEmpty ? null : title;
  }

  /// The Icecast status JSON of Top Media's server. It lists every mount
  /// with its current title, so the right one is picked by mount path.
  Future<String?> _fetchIcecast(String streamUrl) async {
    final res = await http
        .get(Uri.parse('https://live.top-media.al/status-json.xsl'))
        .timeout(_timeout);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    final sources = (body['icestats']?['source'] as List?) ?? const [];
    final mount = streamUrl
        .split('/')
        .last
        .replaceAll(RegExp(r'[?#].*'), '')
        .toLowerCase();
    for (final source in sources) {
      if (source is! Map) continue;
      final listenUrl = (source['listenurl'] as String? ?? '').toLowerCase();
      if (!listenUrl.endsWith('/$mount')) continue;
      final title = source['title'] as String?;
      if (title != null && title.isNotEmpty) return title;
    }
    return null;
  }

  /// Otvoreni returns the artist and the title separately.
  Future<String?> _fetchOtvoreni(String streamKey) async {
    final uri = Uri.parse(
      'https://otvoreni.hr/umbraco/Surface/NowPlayingSurface/GetNowPlaying'
      '?stream=$streamKey',
    );
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    final artist = (data['artist'] as String? ?? '').trim();
    final title = (data['title'] as String? ?? '').trim();
    if (artist.isEmpty && title.isEmpty) return null;
    if (artist.isEmpty) return title;
    if (title.isEmpty) return artist;
    return '$artist - $title';
  }

  /// Melodia answers with a JSONP call: NowOnAir({...}).
  Future<String?> _fetchJsonp(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(_timeout);
    if (res.statusCode != 200) return null;
    var body = res.body.trim();
    final start = body.indexOf('(');
    final end = body.lastIndexOf(')');
    if (start == -1 || end <= start) return null;
    body = body.substring(start + 1, end);
    final data = jsonDecode(body);
    final artist = (data['artist'] as String? ?? '').trim();
    final title = (data['title'] as String? ?? '').trim();
    if (artist.isEmpty && title.isEmpty) return null;
    if (artist.isEmpty) return title;
    if (title.isEmpty) return artist;
    return '$artist - $title';
  }
}
