import 'dart:convert';

import 'dart:io';

import 'package:balkan_radio/data/station_repository.dart';
import 'package:balkan_radio/models/radio_station.dart';
import 'package:balkan_radio/services/update_service.dart';
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

  // The update check compares version.json against these two constants. If they
  // drift from pubspec.yaml the app either never updates or always claims to.
  test('update service constants match pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9.]+)\+(\d+)', multiLine: true)
        .firstMatch(pubspec)!;
    expect(AppUpdate.currentVersionName, match.group(1));
    expect(AppUpdate.currentVersionCode, int.parse(match.group(2)!));
    expect(AppUpdate.currentVersionName, appVersion);
  });

  test('version.json publishes the running version, not an older one', () {
    final meta = jsonDecode(File('version.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(meta['versionName'], AppUpdate.currentVersionName);
    expect(meta['versionCode'], AppUpdate.currentVersionCode);
    expect(meta['apkUrl'] as String, contains('releases/download'));
  });

  test('an update is offered only when it is strictly newer', () {
    const older = AppUpdate(
        versionName: '1.0.0', versionCode: 1, apkUrl: 'http://x/a.apk');
    const same = AppUpdate(
        versionName: '1.3.14', versionCode: 28, apkUrl: 'http://x/a.apk');
    const newer = AppUpdate(
        versionName: '9.9.9', versionCode: 99, apkUrl: 'http://x/a.apk');
    expect(older.isNewer, isFalse);
    expect(same.isNewer, isFalse);
    expect(newer.isNewer, isTrue);
  });

  test('each version downloads to its own file name', () {
    const a = AppUpdate(versionName: '1.3.15', versionCode: 29, apkUrl: 'u');
    const b = AppUpdate(versionName: '1.4.0', versionCode: 30, apkUrl: 'u');
    expect(a.fileName, 'BalkanRadio-1.3.15.apk');
    expect(a.fileName, isNot(b.fileName));
  });
}
