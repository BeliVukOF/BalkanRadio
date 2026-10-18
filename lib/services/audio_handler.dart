import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';

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

  AudioPlayer get player => _player;

  PlaybackState _state() => PlaybackState(
        controls: [
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
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
    mediaItem.add(MediaItem(
      id: station.streamUrl,
      title: station.name,
      album: station.region,
      artist: 'Balkan Radio',
    ));
    try {
      await _player.stop();
      // 30s, not 15: some ICY/HLS servers take that long on mobile data.
      await _player.setUrl(station.streamUrl).timeout(const Duration(seconds: 30));
      if (token != _playToken) return;
      await _player.play();
    } catch (_) {
      if (token != _playToken) return;
      mediaItem.add(null);
      rethrow;
    }
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
