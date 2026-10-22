import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';
import 'car_browse.dart';

/// Starts the platform media service. Falls back to a plain handler (playback
/// works, media notification does not) so the app can never be blocked by a
/// service that refuses to start.
Future<RadioAudioHandler> initAudioService() async {
  try {
    return await AudioService.init(
      builder: RadioAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.belivuk.balkan_radio.channel.audio',
        androidNotificationChannelName: 'Balkan Radio playback',
        androidNotificationOngoing: false,
        // Keeps the service in the foreground while paused, so resuming never
        // hits ForegroundServiceStartNotAllowedException on Android 12+.
        androidStopForegroundOnPause: false,
      ),
    ).timeout(const Duration(seconds: 8));
  } catch (error, stack) {
    debugPrint('AudioService unavailable, using local playback: $error\n$stack');
    return RadioAudioHandler();
  }
}

class RadioAudioHandler extends BaseAudioHandler {
  RadioAudioHandler() {
    _player.playbackEventStream.listen(
      (_) => playbackState.add(_state()),
      onError: (Object error, StackTrace _) {
        // Post-start failures (dropped connection, dead ICY server) used to be
        // swallowed, which left the UI buffering forever with no message.
        debugPrint('playback error: $error');
        this.error.value = error.toString();
        playbackState.add(_state().copyWith(playing: false));
      },
    );
  }

  final AudioPlayer _player = AudioPlayer();

  /// Non-null while the last playback attempt failed after it had started.
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /// Last request wins: a slow station that fails later must not clear the
  /// station the user has already switched to.
  int _playToken = 0;

  /// Station list offered to the car (Android Auto); the provider keeps it
  /// in sync. Empty until stations load, which is fine — the car re-queries.
  List<RadioStation> browseStations = const [];

  AudioPlayer get player => _player;

  /// Off by default: the notification keeps the square stop button. When true
  /// the stop control is an X, in the notification and on the lock screen too.
  bool useStopX = false;

  /// X instead of the square; audio_service sends it as a custom action, which
  /// is the only way to change the notification icon (Android owns the icon of
  /// the built-in stop action).
  static final MediaControl _stopX = MediaControl.custom(
    androidIcon: 'drawable/balkan_stop_x',
    label: 'Stop',
    name: 'stop',
  );

  /// Re-publishes the state so the notification redraws after a control
  /// change. Toggling the X in Settings changed [useStopX] but nothing emitted
  /// a new playbackState, so the notification and lock screen kept the old
  /// icon until some unrelated playback event happened to fire.
  void refreshControls() => playbackState.add(_state());

  PlaybackState _state() => PlaybackState(
        controls: [
          if (_player.playing) MediaControl.pause else MediaControl.play,
          if (useStopX) _stopX else MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
      );

  /// Throws when the stream cannot be opened, so the UI can tell the user.
  Future<void> playStation(RadioStation station) async {
    final token = ++_playToken;
    error.value = null;
    mediaItem.add(carStationItem(station));
    try {
      await _player.stop();
      // 30s, not 15: some ICY/HLS servers take that long on mobile data.
      await _player.setUrl(station.streamUrl).timeout(const Duration(seconds: 30));
      if (token != _playToken) return;
      // Do not await: on a live stream play() only returns once enough has
      // buffered, which can take seconds. The caller must not wait for audio
      // just to open the player.
      unawaited(_player.play());
    } catch (_) {
      if (token != _playToken) return;
      mediaItem.add(null);
      rethrow;
    }
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    if (parentMediaId == AudioService.recentRootId) {
      // "Recent" is what is playing now, so the car can resume it.
      final current = mediaItem.value;
      return current == null ? const [] : [current];
    }
    return carBrowseChildren(parentMediaId, browseStations);
  }

  /// Tapping a station in the car. Errors must not escape into the service.
  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    for (final station in browseStations) {
      if (station.streamUrl != mediaId) continue;
      try {
        await playStation(station);
      } catch (error) {
        debugPrint('car playback failed: $error');
      }
      return;
    }
  }

  /// The X is a custom action: only a custom action can carry its own
  /// notification icon, and it must still land on the same stop behaviour.
  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) {
    if (name == 'stop') return stop();
    return super.customAction(name, extras);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    _playToken++;
    error.value = null;
    await _player.stop();
    mediaItem.add(null);
    await super.stop();
  }
}
