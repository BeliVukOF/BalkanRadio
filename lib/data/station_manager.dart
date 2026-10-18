import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

class StationManager {
  static const String _cacheKey = 'stations_cache_v2';

  static const List<String> _regions = [
    'albania',
    'bosnia',
    'bulgaria',
    'croatia',
    'greece',
    'macedonia',
    'montenegro',
    'serbia',
  ];

  String _remoteUrl(String region) =>
      'https://raw.githubusercontent.com/BeliVukOF/Radio-app/main/stations/$region.json';

  /// Network only. Returns an empty list when every region failed.
  Future<List<RadioStation>> fetchStations() async {
    final results = await Future.wait(_regions.map(_fetchRegionStations));
    final stations = [for (final region in results) ...region];
    if (stations.isNotEmpty) await _saveToCache(stations);
    return stations;
  }

  Future<List<RadioStation>?> cachedStations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<RadioStation>> _fetchRegionStations(String region) async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl(region)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return decoded
          .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveToCache(List<RadioStation> stations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(stations.map((s) => s.toJson()).toList()),
      );
    } catch (_) {
      // A failed cache write must never block playback.
    }
  }
}
