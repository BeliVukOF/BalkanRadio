import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

class StationManager {
  static const String _cacheKey = 'stations_cache_v4';

  static const List<String> regions = [
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
      'https://raw.githubusercontent.com/BeliVukOF/BalkanRadio/main/stations/$region.json';

  /// Network only, one entry per region. A region that fails is simply absent
  /// from the map, so the caller can merge and never lose the regions it
  /// already had.
  Future<Map<String, List<RadioStation>>> fetchStations() async {
    final results = await Future.wait(regions.map(_fetchRegionStations));
    final byRegion = <String, List<RadioStation>>{};
    for (var i = 0; i < regions.length; i++) {
      if (results[i].isNotEmpty) byRegion[regions[i]] = results[i];
    }
    return byRegion;
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

  Future<void> saveToCache(List<RadioStation> stations) async {
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
