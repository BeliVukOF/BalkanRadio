import 'dart:async';

import 'package:flutter/services.dart' show SystemNavigator;
import 'package:audio_service/audio_service.dart' show AudioProcessingState;
import 'package:flutter/material.dart';

import '../data/region_preferences.dart';
import '../data/station_manager.dart';
import '../data/station_repository.dart';
import '../models/radio_station.dart';
import '../services/audio_handler.dart';

class RadioProvider extends ChangeNotifier {
  RadioProvider() {
    _init();
  }

  final RegionPreferences prefs = RegionPreferences();
  final StationManager stationManager = StationManager();

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Completer<void> _audioReady = Completer<void>();
  RadioAudioHandler? _audio;
  List<RadioStation> _allStations = [];
  RadioStation? _currentStation;
  bool _isLoading = false;
  bool _disposed = false;
  bool _playPending = false;
  Timer? _sleepTimer;
  DateTime? _sleepDeadline;
  bool _sleepClosesApp = false;
  int _playToken = 0;
  String _searchQuery = '';

  List<RadioStation> get allStations => _allStations;
  RadioStation? get currentStation => _currentStation;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isPlaying => _audio?.playbackState.value.playing ?? false;
  String? get playbackError => _audio?.error.value;
  /// true while a sleep timer is armed.
  bool get sleepActive => _sleepDeadline != null;

  /// Time left on the armed sleep timer; null when none is set.
  Duration? get sleepRemaining {
    final deadline = _sleepDeadline;
    if (deadline == null) return null;
    final left = deadline.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  List<String> get availableRegions => StationManager.regions
      .map((r) => r[0].toUpperCase() + r.substring(1))
      .toList();
  List<String> get enabledRegions =>
      availableRegions.where(prefs.isRegionEnabled).toList();

  bool get isBuffering => switch (_audio?.playbackState.value.processingState) {
        AudioProcessingState.loading || AudioProcessingState.buffering => true,
        _ => false,
      };

  /// 'classic' | 'bold'
  String get design => prefs.design;

  ThemeMode get themeMode => switch (prefs.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  /// null means "follow the system language".
  Locale? get locale {
    final code = prefs.appLanguage;
    return code == 'system' ? null : Locale(code);
  }

  Future<void> _init() async {
    try {
      await RegionPreferences.init();
    } catch (error, stack) {
      // Unreadable preferences must not stop the app from opening, but they
      // must be visible: every settings toggle silently dies without storage.
      debugPrint('RegionPreferences.init failed: $error\n$stack');
    }

    unawaited(loadStations());

    try {
      _audio = await initAudioService();
    } catch (error, stack) {
      debugPrint('audio init failed: $error\n$stack');
      _audio = RadioAudioHandler();
    }

    _subscriptions.add(_audio!.mediaItem.listen((item) {
      _currentStation = item == null
          ? null
          : _allStations.firstWhere(
              (s) => s.streamUrl == item.id,
              orElse: () => RadioStation(
                name: item.title,
                streamUrl: item.id,
                region: item.album ?? '',
              ),
            );
      _notify();
    }));
    _subscriptions.add(_audio!.playbackState.listen((_) => _notify()));
    _audio!.error.addListener(_notify);

    _notify();
    // Always completes, even when init above threw: playback calls must never
    // wait forever on a completer nobody finishes.
    if (!_audioReady.isCompleted) _audioReady.complete();
  }

  void _notify() {
    // Android Auto browses from the handler: keep its tree on the current list.
    _audio?.browseStations = _allStations;
    if (!_disposed) notifyListeners();
  }

  /// Shows the cached list straight away, then refreshes from the network.
  /// A region that fails keeps its previous entries: a partial fetch never
  /// shrinks the list or the cache.
  Future<bool> loadStations() async {
    if (_playPending) return false;
    _playPending = true;

    try {
      if (_allStations.isEmpty) {
        final cached = await stationManager.cachedStations();
        _allStations = cached != null && cached.isNotEmpty
            ? cached
            : StationRepository.allStations;
        _notify();
      }

      _isLoading = true;
      _notify();

      var refreshed = false;
      try {
        final fetched = await stationManager.fetchStations();
        if (fetched.isNotEmpty) {
          _allStations = _merge(_allStations, fetched);
          unawaited(stationManager.saveToCache(_allStations));
          refreshed = fetched.length == StationManager.regions.length;
        }
      } catch (error) {
        debugPrint('station refresh failed: $error');
      }

      _isLoading = false;
      _notify();
      return refreshed;
    } finally {
      _playPending = false;
    }
  }

  /// Keeps every station whose region did not come back from the network.
  List<RadioStation> _merge(
    List<RadioStation> existing,
    Map<String, List<RadioStation>> fetched,
  ) {
    final fetchedNames = fetched.keys.toSet();
    final kept = existing.where((s) {
      final region = s.region.toLowerCase();
      return !fetchedNames.contains(region);
    });
    return [...fetched.values.expand((s) => s), ...kept];
  }

  List<RadioStation> getFilteredStations({
    String? region,
    bool isFavoritesOnly = false,
    String Function(String)? regionLabeler,
  }) {
    var list = _allStations.toList();

    if (isFavoritesOnly) {
      // Favourites are chosen by the user, so they must not disappear when a
      // region is switched off.
      list = list.where((s) => prefs.isStationFavorite(s.streamUrl)).toList();
    } else {
      list = list.where((s) => prefs.isRegionEnabled(s.region)).toList();
      if (region != null && region.isNotEmpty) {
        list = list.where((s) => s.region == region).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((s) {
        if (s.name.toLowerCase().contains(query)) return true;
        if (s.region.toLowerCase().contains(query)) return true;
        // Region names on screen are localised ("Grčka"), so search them too.
        final label = regionLabeler?.call(s.region);
        return label != null && label.toLowerCase().contains(query);
      }).toList();
    }

    // Favourites on top, then everything else, each group alphabetical.
    list.sort((a, b) {
      final aFav = prefs.isStationFavorite(a.streamUrl);
      final bFav = prefs.isStationFavorite(b.streamUrl);
      if (aFav != bFav) return aFav ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return list;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _notify();
  }

  /// Returns false when the stream could not be opened.
  Future<bool> playStation(RadioStation station) async {
    final token = ++_playToken;
    _currentStation = station;
    _notify();

    await _audioReady.future;
    try {
      await _audio!.playStation(station);
      return true;
    } catch (error) {
      debugPrint('play failed: $error');
      // Only clear the station if the user has not switched to another one.
      if (token == _playToken) {
        _currentStation = null;
        _notify();
      }
      return false;
    }
  }

  Future<void> togglePlayPause() async {
    await _audioReady.future;
    if (isPlaying) {
      await _audio!.pause();
    } else if (_currentStation != null) {
      await _audio!.play();
    }
  }

  Future<void> stop() async {
    _playToken++;
    _currentStation = null;
    _notify();
    await _audioReady.future;
    await _audio!.stop();
  }

  /// Stops playback after [duration]; null cancels. With [closeApp] the app
  /// also leaves the UI when the timer fires. A real force-stop is not
  /// something an app can do to itself, so this is the honest version.
  void setSleepTimer(Duration? duration, {bool closeApp = false}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepDeadline = null;
    _sleepClosesApp = closeApp;

    if (duration != null) {
      _sleepDeadline = DateTime.now().add(duration);
      _sleepTimer = Timer(duration, () {
        _sleepTimer = null;
        _sleepDeadline = null;
        unawaited(stop());
        if (_sleepClosesApp) SystemNavigator.pop();
        _notify();
      });
    }
    _notify();
  }

  Future<void> toggleFavorite(RadioStation station) async {
    await prefs.toggleFavorite(station.streamUrl);
    _notify();
  }

  /// Returns false when the last enabled region would be switched off.
  Future<bool> setRegionEnabled(String region, bool enabled) async {
    final enabledRegions = this.enabledRegions;
    if (!enabled && enabledRegions.length <= 1 && enabledRegions.contains(region)) {
      return false;
    }
    await prefs.setRegionEnabled(region, enabled);
    _notify();
    return true;
  }

  Future<void> setPowerSavingEnabled(bool enabled) async {
    await prefs.setPowerSavingEnabled(enabled);
    _notify();
  }

  Future<void> setDesign(String value) async {
    await prefs.setDesign(value);
    _notify();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setThemeMode(switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    _notify();
  }

  Future<void> setAppLanguage(String code) async {
    await prefs.setAppLanguage(code);
    _notify();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _disposed = true;
    _audio?.error.removeListener(_notify);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
