import 'package:balkan_radio/ui/bold/bold_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05));
}

void main() {
  test('monogram takes two letters, from two words or from one', () {
    expect(BoldTheme.monogram('Radio Dunav'), 'RD');
    expect(BoldTheme.monogram('Rock'), 'RO');
    expect(BoldTheme.monogram('X'), 'X');
    expect(BoldTheme.monogram('  '), '•');
  });

  test('every station name lands on the same tile every time', () {
    expect(BoldTheme.tileFor('Radio Dunav'), BoldTheme.tileFor('Radio Dunav'));
    final used = {
      for (final name in [
        'Radio Dunav',
        'Jadran FM',
        'Kiss FM',
        'Art FM',
        'Play Radio'
      ])
        BoldTheme.tileFor(name).first,
    };
    expect(used.length, greaterThan(1));
  });

  test('country codes cover all eight regions', () {
    for (final region in [
      'Albania',
      'Bosnia',
      'Bulgaria',
      'Croatia',
      'Greece',
      'Macedonia',
      'Montenegro',
      'Serbia',
    ]) {
      expect(BoldTheme.countryCodes[region], isNotNull, reason: region);
    }
  });

  test('white text is readable on every tile gradient end', () {
    for (final tile in BoldTheme.tiles) {
      for (final color in tile) {
        expect(contrast(Colors.white, color), greaterThanOrEqualTo(4.5),
            reason: 'tile $color');
      }
    }
  });

  test('cyber palette keeps its neon colours distinct and sharp corners', () {
    for (final palette in [BoldTheme.cyberDark, BoldTheme.cyberLight]) {
      expect(palette.neon, isTrue);
      expect(palette.neonA, isNot(palette.neonB));
      expect(palette.corners(26), 0);
      expect(palette.frame, isNotNull);
      expect(palette.shadow, isNotEmpty);
    }
    // The bold design keeps its rounded corners and no frames.
    expect(BoldTheme.dark.corners(26), 26);
    expect(BoldTheme.dark.frame, isNull);

    // Same station, same neon frame, like the tiles.
    expect(BoldTheme.neonFor('Radio Dunav'), BoldTheme.neonFor('Radio Dunav'));
    expect(BoldTheme.neonFor('Jadran FM'), isIn(BoldTheme.neonTiles));
  });

  test('accent and body text are readable in both variants', () {
    for (final palette in [
      BoldTheme.dark,
      BoldTheme.light,
      BoldTheme.cyberDark,
      BoldTheme.cyberLight,
    ]) {
      expect(contrast(palette.accent, palette.onAccent),
          greaterThanOrEqualTo(4.5));
      expect(contrast(palette.background, palette.text),
          greaterThanOrEqualTo(4.5));
      expect(contrast(palette.background, palette.textMuted),
          greaterThanOrEqualTo(4.5));
      // Active nav labels sit on the background, not on the accent.
      expect(contrast(palette.background, palette.highlight),
          greaterThanOrEqualTo(4.5));
    }
  });
}
