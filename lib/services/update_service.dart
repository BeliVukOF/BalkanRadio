import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MissingPluginException, MethodChannel, PlatformException;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// An update the app can install, as published in `version.json` on GitHub.
class AppUpdate {
  const AppUpdate({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    this.sha256 = '',
  });

  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String sha256;

  factory AppUpdate.fromJson(Map<String, dynamic> json) => AppUpdate(
        versionName: json['versionName'] as String? ?? '',
        versionCode: (json['versionCode'] as num?)?.toInt() ?? 0,
        apkUrl: json['apkUrl'] as String? ?? '',
        sha256: json['sha256'] as String? ?? '',
      );

  /// Kept in sync with pubspec.yaml by a unit test.
  static const String currentVersionName = '1.3.19';
  static const int currentVersionCode = 33;

  bool get isNewer => versionCode > currentVersionCode;

  /// Distinct file per version: a retry must not reuse a half-written file.
  String get fileName => 'BalkanRadio-$versionName.apk';
}

/// Checks `version.json`, downloads a newer APK in the background through the
/// system DownloadManager and hands it to the installer.
///
/// The installer dialog cannot be suppressed: Android requires the user to
/// confirm, and kills the app once the install starts. Everything before that
/// - the check and the download - happens silently in the background.
class UpdateService extends ChangeNotifier {
  UpdateService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('balkan_radio/update');

  final MethodChannel _channel;

  static const String _metaUrl =
      'https://raw.githubusercontent.com/BeliVukOF/BalkanRadio/main/version.json';
  static const String _skipKey = 'update_skipped_version';

  AppUpdate? _available;
  bool _checking = false;
  bool _downloading = false;
  bool _permissionMissing = false;
  int _downloadId = -1;
  int _progress = 0;
  String? _readyPath;
  Timer? _poll;

  AppUpdate? get available => _available;
  bool get checking => _checking;
  bool get downloading => _downloading;
  bool get permissionMissing => _permissionMissing;

  /// 0..100 while downloading.
  int get progress => _progress;

  /// Set once the APK is on disk; the UI then offers the install button.
  String? get readyPath => _readyPath;

  /// The update is downloaded and only waiting for the user to install it.
  bool get isReadyToInstall => _readyPath != null && !_downloading;

  /// Silent check at start-up. A failure is never shown: no update is not news.
  Future<void> checkAtStartup() async {
    try {
      final update = await fetchUpdate();
      if (update == null || !update.isNewer) return;
      if (await isSkipped(update)) return;
      _available = update;
      notifyListeners();
    } catch (error) {
      debugPrint('update check failed: $error');
    }
  }

  /// Explicit check from Settings: reports every outcome to the caller.
  Future<AppUpdate?> checkNow() async {
    _checking = true;
    notifyListeners();
    try {
      final update = await fetchUpdate();
      if (update == null || !update.isNewer) return null;
      _available = update;
      await clearSkip(update);
      return update;
    } catch (error) {
      debugPrint('update check failed: $error');
      return null;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  Future<AppUpdate?> fetchUpdate() async {
    if (kIsWeb) return null;
    final response = await http
        .get(Uri.parse(_metaUrl))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    return AppUpdate.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<bool> isSkipped(AppUpdate update) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_skipKey) == update.versionCode;
  }

  Future<void> skip(AppUpdate update) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_skipKey, update.versionCode);
    _available = null;
    notifyListeners();
  }

  /// "Later" only silences this version; a newer one still asks.
  Future<void> clearSkip(AppUpdate update) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_skipKey) == update.versionCode) {
      await prefs.remove(_skipKey);
    }
  }

  /// True when Android has not been asked yet to allow this app to install.
  Future<bool> needsInstallPermission() async {
    if (kIsWeb) return false;
    try {
      return !(await _channel.invokeMethod<bool>('canRequestPackageInstalls') ?? true);
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> requestInstallPermission() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<bool>('requestInstallPermission');
    } on PlatformException {
      // Nothing to do: the platform screen either opened or does not exist.
    } on MissingPluginException {
      // Same: without the channel there is no permission to ask for.
    }
  }

  /// Queues the download and polls until it lands. The download itself runs in
  /// the system DownloadManager, so it survives the app being closed.
  Future<bool> download(AppUpdate update) async {
    _permissionMissing = await needsInstallPermission();
    if (_permissionMissing) {
      notifyListeners();
      return false;
    }
    _downloading = true;
    _available = update;
    _progress = 0;
    _readyPath = null;
    notifyListeners();
    try {
      final id = await _channel.invokeMethod<int>('enqueueDownload', {
        'url': update.apkUrl,
        'fileName': update.fileName,
      });
      if (id == null || id < 0) return false;
      _downloadId = id;
      return await _pollUntilDone(update);
    } on PlatformException catch (error) {
      debugPrint('update download failed: $error');
      return false;
    } on MissingPluginException {
      return false;
    } finally {
      _downloading = false;
      notifyListeners();
    }
  }

  Future<bool> _pollUntilDone(AppUpdate update) async {
    final completer = Completer<bool>();
    _poll = Timer.periodic(const Duration(milliseconds: 900), (timer) async {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'downloadStatus',
        {'id': _downloadId, 'fileName': update.fileName},
      );
      final state = result?['state'] as String?;
      final percent = (result?['progress'] as num?)?.toInt() ?? _progress;
      if (percent != _progress) {
        _progress = percent;
        notifyListeners();
      }
      if (state == 'failed') {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(false);
        return;
      }
      if (state == 'ok') {
        timer.cancel();
        final path = result?['path'] as String?;
        _readyPath = path;
        _progress = path == null ? 0 : 100;
        if (!completer.isCompleted) completer.complete(path != null);
      }
    });
    final done = await completer.future;
    _poll = null;
    return done;
  }

  /// Opens the system installer. The user confirms there; Android restarts the
  /// app itself after a package replace.
  Future<bool> install(AppUpdate update) async {
    // Re-query: the file may have been removed from Downloads since the
    // download finished, and installing a missing file just fails silently.
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'downloadStatus',
      {'id': _downloadId, 'fileName': update.fileName},
    );
    final path = result?['path'] as String? ?? _readyPath;
    if (path == null) return false;
    try {
      return await _channel.invokeMethod<bool>('installApk', {'path': path}) ?? false;
    } on PlatformException catch (error) {
      debugPrint('install failed: $error');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}
