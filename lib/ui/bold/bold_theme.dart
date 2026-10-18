import 'package:flutter/material.dart';

/// Colours of one design variant. Two instances exist: [BoldTheme.dark] and
/// [BoldTheme.light]; widgets read them through [BoldTheme.of].
class BoldPalette {
  const BoldPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.textMuted,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color textMuted;
}

/// Palette for the "Bold" design: one orange accent plus saturated two-tone
/// tiles, in a dark and a light variant.
abstract final class BoldTheme {
  static const BoldPalette dark = BoldPalette(
    background: Color(0xFF0E0E11),
    surface: Color(0xFF17171B),
    surfaceHigh: Color(0xFF1F1F25),
    accent: Color(0xFFFF6B35),
    onAccent: Color(0xFF160F0A),
    text: Color(0xFFF6F6F8),
    textMuted: Color(0xFF9C9CA6),
  );

  /// Accent is darker than the mock's orange: #FF6B35 on a light background is
  /// only 2.6:1, the nav labels and icons need 4.5:1.
  static const BoldPalette light = BoldPalette(
    background: Color(0xFFF6F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFEDECF0),
    accent: Color(0xFFC2410C),
    onAccent: Color(0xFFFFFFFF),
    text: Color(0xFF14141A),
    textMuted: Color(0xFF5F5F6A),
  );

  static BoldPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Top-to-bottom gradients; the first colour is also the monogram background.
  static const List<List<Color>> tiles = [
    [Color(0xFF2F4BC7), Color(0xFF3D5AE0)],
    // Second stop kept dark enough for white text (>= 4.5:1), not the mock's
    // lighter amber which landed on 4.03:1.
    [Color(0xFF96461A), Color(0xFFB05519)],
    [Color(0xFF0F6B5C), Color(0xFF17836F)],
    [Color(0xFFA81C63), Color(0xFFC22872)],
    [Color(0xFF6B21C9), Color(0xFF7E33E0)],
    [Color(0xFFA81F1F), Color(0xFFC22A2A)],
    [Color(0xFF1B4F9E), Color(0xFF2563B8)],
    [Color(0xFF0B5F69), Color(0xFF12747F)],
  ];

  static const Map<String, String> countryCodes = {
    'Albania': 'AL',
    'Bosnia': 'BA',
    'Bulgaria': 'BG',
    'Croatia': 'HR',
    'Greece': 'GR',
    'Macedonia': 'MK',
    'Montenegro': 'ME',
    'Serbia': 'RS',
  };

  /// Same name always gets the same tile, so colours stay put between launches.
  static List<Color> tileFor(String seed) => tiles[_hash(seed) % tiles.length];

  /// Two-letter monogram: "Radio Dunav" -> "RD", "Rock" -> "RO".
  static String monogram(String name) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '•';
    if (words.length == 1) {
      final word = words.first;
      return (word.length > 1 ? word.substring(0, 2) : word).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  static int _hash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  static ThemeData get darkTheme => _build(dark, Brightness.dark);
  static ThemeData get lightTheme => _build(light, Brightness.light);

  static ThemeData _build(BoldPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: brightness == Brightness.dark ? const Color(0xFFFF6B6B) : const Color(0xFFB3261E),
      onError: p.onAccent,
      surface: p.surface,
      onSurface: p.text,
      surfaceContainerHighest: p.surfaceHigh,
      onSurfaceVariant: p.textMuted,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surfaceHigh,
        contentTextStyle: TextStyle(color: p.text),
      ),
      dividerTheme: DividerThemeData(color: p.surfaceHigh, thickness: 1),
    );
  }
}
