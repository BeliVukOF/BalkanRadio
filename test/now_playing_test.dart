import 'package:balkan_radio/services/now_playing_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live check of every title source the app uses.
///
/// Each case names a stream URL that ships in stations/*.json and asserts the
/// service can pull a real title for it. The stations were chosen so that
/// every fetch path is covered: plain text, Icecast JSON, the Otvoreni JSON
/// endpoint and the Melodia JSONP endpoint.
///
/// The endpoints are external, so a network failure must fail the test
/// rather than silently pass.
void main() {
  test('Extra FM live publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor(
      'https://relay2.social3.hr/radio/8190/radio.mp3',
    );
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Extra FM live      -> $title');
  });

  test('Extra FM throwback publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor(
      'https://relay2.social3.hr/radio/8170/radio.mp3',
    );
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Extra FM throwback -> $title');
  });

  test('Extra FM fresh publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor(
      'https://relay1.social3.hr/radio/8360/radio.mp3',
    );
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Extra FM fresh     -> $title');
  });

  test('Top Albanian Radio publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor('https://live.top-media.al/tar');
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Top Albanian Radio -> $title');
  });

  test('My Music Radio publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor('https://live.top-media.al/mmr');
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('My Music Radio     -> $title');
  });

  test('Otvoreni Live publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor('https://stream.otvoreni.hr/otvoreni');
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Otvoreni Live      -> $title');
  });

  test('Otvoreni Chill publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor('https://stream.otvoreni.hr/chill');
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Otvoreni Chill     -> $title');
  });

  test('Melodia FM publishes a title', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor(
      'https://stream.rcs.revma.com/8tdwa6ez1duvv',
    );
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Melodia FM         -> $title');
  });

  test('Play Radio publishes a title over its websocket', () async {
    final service = NowPlayingService();
    final title = await service.fetchTitleFor(
      'http://stream.playradio.rs:8001/play.mp3',
    );
    expect(title, isNotNull);
    expect(title!.trim(), isNotEmpty);
    // ignore: avoid_print
    print('Play Radio         -> $title');
  });

  test('stations without a public title source report none', () async {
    final service = NowPlayingService();
    // Dzungla, MRT, TDI, En Lefko and Kanal 103 were all checked: none of
    // them publishes a title anywhere, so the app must not invent one.
    for (final url in const [
      'https://cast2.name.ba/proxy/dzungla/stream',
      'https://vod-c57.interspace.com/channel_abr/47/playlist.m3u8',
      'http://streaming.tdiradio.com/radiolola.mp3',
      'https://stream.rcs.revma.com/kwste9dz1duvv',
      'http://radiostream.neotel.mk/kanal103',
    ]) {
      expect(service.supportsTitle(url), isFalse, reason: url);
      expect(await service.fetchTitleFor(url), isNull, reason: url);
    }
  });
}
