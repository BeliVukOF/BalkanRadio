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
      BoldTheme.modernDark,
      BoldTheme.modernLight,
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

  test('modern: glass cards over a gradient backdrop, readable orbs', () {
    for (final palette in [BoldTheme.modernDark, BoldTheme.modernLight]) {
      expect(palette.modern, isTrue);
      expect(palette.backdrop, isNotNull);
      expect(palette.glass.a, lessThan(1)); // frosted, not opaque
      // Modern pills carry a hairline rim; it must stay subtle, not a frame.
      final rim = palette.glassFrame;
      expect(rim, isNotNull);
      expect(rim!.top.width, lessThanOrEqualTo(1.5));
      expect(rim.top.color.a, lessThan(0.6)); // translucent pane, not an edge
      // Body text must clear the worst stop of the backdrop, not the flat one.
      for (final stop in palette.backdrop!) {
        expect(contrast(stop, palette.text), greaterThanOrEqualTo(4.5),
            reason: 'text on $stop');
        expect(contrast(stop, palette.textMuted), greaterThanOrEqualTo(4.5),
            reason: 'muted on $stop');
      }
      // White glyphs on the play orbs: 3:1 is the bar for graphics.
      for (final stop in palette.playGradient!) {
        expect(contrast(Colors.white, stop), greaterThanOrEqualTo(3),
            reason: 'play glyph on $stop');
      }
      // White chip labels are text, so 4.5:1.
      for (final stop in palette.chipGradient!) {
        expect(contrast(Colors.white, stop), greaterThanOrEqualTo(4.5),
            reason: 'chip label on $stop');
      }
    }
    // Classic and Cyberpunk have no gradient decorations.
    expect(BoldTheme.dark.playGradient, isNull);
    expect(BoldTheme.cyberDark.chipGradient, isNull);
  });
}
