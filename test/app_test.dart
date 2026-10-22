
import 'dart:convert';
import 'dart:io';

import 'package:balkan_radio/data/station_repository.dart';
import 'package:balkan_radio/models/radio_station.dart';
import 'package:balkan_radio/ui/screens/settings_screen.dart' show appVersion;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RadioStation round-trips through json', () {
    const station = RadioStation(
      name: 'Radio S 1',
      streamUrl: 'https://example.com/s1',
      region: 'Serbia',
    );
    final copy = RadioStation.fromJson(station.toJson());
    expect(copy.name, station.name);
    expect(copy.streamUrl, station.streamUrl);
    expect(copy.region, station.region);
  });

  test('RadioStation equality is by stream url', () {
    const a = RadioStation(name: 'A', streamUrl: 'u', region: 'Serbia');
    const b = RadioStation(name: 'A renamed', streamUrl: 'u', region: 'Serbia');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('Missing json fields fall back to empty strings', () {
    final station = RadioStation.fromJson(const {});
    expect(station.name, isEmpty);
    expect(station.streamUrl, isEmpty);
  });

  test('bundled fallback covers every station in stations/*.json', () {
    final bundled = StationRepository.allStations.map((s) => s.streamUrl).toSet();
    for (final file in Directory('stations').listSync()) {
      if (!file.path.endsWith('.json')) continue;
      final items = jsonDecode(File(file.path).readAsStringSync()) as List<dynamic>;
      for (final item in items) {
        final url = (item as Map<String, dynamic>)['streamUrl'] as String;
        expect(bundled, contains(url),
            reason: '${file.path} has $url, missing from the bundled fallback');
      }
    }
  });

  test('about version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1);
    expect(appVersion, version);
  });
}
