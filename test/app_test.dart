import 'dart:io';

import 'package:balkan_radio/models/radio_station.dart';
import 'package:balkan_radio/ui/screens/settings_screen.dart' show appVersion;
import 'package:balkan_radio/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

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

  for (final entry in {
    'light': AppTheme.light,
    'dark': AppTheme.dark,
  }.entries) {
    test('${entry.key} theme keeps body text readable', () {
      final scheme = entry.value.colorScheme;
      expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(4.5));
      expect(_contrast(scheme.onSurfaceVariant, scheme.surface), greaterThan(4.5));
      expect(_contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
          greaterThan(4.5));
      expect(_contrast(scheme.onPrimary, scheme.primary), greaterThan(4.5));
    });
  }

  test('hero gradients keep white text readable', () {
    for (final gradient in [AppTheme.heroLight, AppTheme.heroDark]) {
      for (final colour in gradient.colors) {
        expect(_contrast(Colors.white, colour), greaterThan(4.5),
            reason: 'white on $colour');
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
