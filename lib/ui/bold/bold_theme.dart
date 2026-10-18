import 'package:flutter/material.dart';

/// Colours of one design variant. Instances exist for the "Bold" design
/// ([BoldTheme.dark], [BoldTheme.light]) and the "Cyberpunk" design
/// ([BoldTheme.cyberDark], [BoldTheme.cyberLight]); widgets read the active one
/// through [BoldTheme.of].
///
/// [neon] switches the extra chrome the cyber design needs: grid background,
/// square corners, neon frames and glows.
class BoldPalette {
  const BoldPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.textMuted,
    this.neon = false,
    this.modern = false,
    Color? neonA,
    Color? neonB,
    Color? grid,
    this.backdrop,
  })  : neonA = neonA ?? accent,
        neonB = neonB ?? accent,
        grid = grid ?? const Color(0x00000000);

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color textMuted;

  /// True for the cyber design; every visual difference hangs off this flag.
  final bool neon;

  /// Neon border / kicker colour (cyan on dark, teal on light).
  final Color neonA;

  /// Second neon colour: LIVE badge, hearts (magenta).
  final Color neonB;

  /// Background grid line colour; transparent when [neon] is false.
  final Color grid;

  /// True for the Modern design: gradient backdrop, glass cards, gradient orbs.
  final bool modern;

  /// Backdrop gradient, top-left to bottom-right; null keeps a flat background.
  final List<Color>? backdrop;

  /// Card colour: frosted glass over the modern backdrop, raised surface else.
  Color get glass => modern ? surface.withValues(alpha: 0.55) : surface;

  /// Hairline border of the glass cards; null when the design has none.
  Border? get glassFrame => modern
      ? Border.all(
          color: text.withValues(alpha: brightness == Brightness.dark ? 0.16 : 0.55),
        )
      : null;

  /// Gradient of play buttons and the player artwork; null = flat accent.
  List<Color>? get playGradient => modern
      ? (brightness == Brightness.dark
          ? const [Color(0xFF1587B8), Color(0xFF3129B8)]
          : const [Color(0xFF0E5C86), Color(0xFF2A2AAE)])
      : null;

  /// Gradient of the selected region chip; null = flat accent.
  List<Color>? get chipGradient => modern
      ? (brightness == Brightness.dark
          ? const [Color(0xFF2F5FE0), Color(0xFF6B45D8)]
          : const [Color(0xFF24409E), Color(0xFF5B2BC0)])
      : null;

  /// Neon frame colour of one station; the light design needs darker shades so
  /// the monogram stays readable on a white tile.
  Color stationColor(String seed) =>
      (brightness == Brightness.dark ? BoldTheme.neonTiles : BoldTheme.neonTilesLight)[
          BoldTheme._hash(seed) % BoldTheme.neonTiles.length];

  Brightness get brightness =>
      background.computeLuminance() < 0.35 ? Brightness.dark : Brightness.light;

  /// Active colour of the bottom bar: accent for bold, neon cyan/magenta.
  Color get highlight =>
      neon ? (brightness == Brightness.dark ? neonA : neonB) : accent;

  /// Corner radius: designs without [neon] keep the given value, cyber is sharp.
  double corners(double base) => neon ? 0 : base;

  /// Border around cards and buttons; null when the design has no frames.
  Border? get frame => neon
      ? Border.all(
          color: brightness == Brightness.dark
              ? neonA.withValues(alpha: 0.55)
              : text,
          width: brightness == Brightness.dark ? 1.2 : 2,
        )
      : null;

  /// Neon glow on dark, hard offset shadow on light, nothing for bold.
  List<BoxShadow> get shadow {
    if (!neon) return const [];
    if (brightness == Brightness.dark) {
      return [BoxShadow(color: neonA.withValues(alpha: 0.28), blurRadius: 16)];
    }
    return const [BoxShadow(color: Color(0xFF0B0B12), offset: Offset(4, 4))];
  }
}

/// Palettes for the two designs, each in a dark and a light variant.
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

  /// Cyberpunk: near-black navy, cyan frames, yellow action buttons.
  static const BoldPalette cyberDark = BoldPalette(
    background: Color(0xFF08080F),
    surface: Color(0xFF101020),
    surfaceHigh: Color(0xFF16162A),
    accent: Color(0xFFE8FF00),
    onAccent: Color(0xFF08080F),
    text: Color(0xFFF4F6FF),
    textMuted: Color(0xFF9AA0B5),
    neon: true,
    neonA: Color(0xFF22D3EE),
    neonB: Color(0xFFFF3DA6),
    grid: Color(0x1422D3EE),
  );

  /// Cyberpunk light variant: paper lavender, black frames, hard offset shadows.
  static const BoldPalette cyberLight = BoldPalette(
    background: Color(0xFFEFEDF5),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF5F3FA),
    accent: Color(0xFFF2E600),
    onAccent: Color(0xFF0B0B12),
    text: Color(0xFF0B0B12),
    textMuted: Color(0xFF5B5B6B),
    neon: true,
    neonA: Color(0xFF0B7285),
    neonB: Color(0xFFC2185B),
    grid: Color(0x1A0B0B12),
  );

  /// Modern: navy/purple/teal backdrop, glass cards, cyan accents.
  static const BoldPalette modernDark = BoldPalette(
    background: Color(0xFF0A1030),
    surface: Color(0xFF1A2246),
    surfaceHigh: Color(0xFF232C55),
    accent: Color(0xFF5CCFE0),
    onAccent: Color(0xFF04121A),
    text: Color(0xFFF3F5FF),
    textMuted: Color(0xFFA6AECB),
    modern: true,
    backdrop: [Color(0xFF0A1030), Color(0xFF241A4E), Color(0xFF0B3A3F)],
  );

  /// Modern light: pale lavender/blue backdrop, white glass, violet accents.
  static const BoldPalette modernLight = BoldPalette(
    background: Color(0xFFE4E9F8),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF2F4FC),
    accent: Color(0xFF4B3FC8),
    onAccent: Color(0xFFFFFFFF),
    text: Color(0xFF0B1233),
    textMuted: Color(0xFF49547A),
    modern: true,
    backdrop: [Color(0xFFC6D7F7), Color(0xFFE8E4F8), Color(0xFFCDEFF6)],
  );

  static BoldPalette of(BuildContext context) =>
      Theme.of(context).extension<_PaletteExt>()?.palette ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

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

  /// Neon frame colours of the cyber design, in the mock's rotation.
  static const List<Color> neonTiles = [
    Color(0xFF22D3EE),
    Color(0xFFFF3DA6),
    Color(0xFFE8FF00),
    Color(0xFF3DFF7A),
    Color(0xFFFF8A2B),
    Color(0xFFA855F7),
  ];

  /// Darker frames for the light design, all >= 4.9:1 on white.
  static const List<Color> neonTilesLight = [
    Color(0xFF0E7490),
    Color(0xFFC2185B),
    Color(0xFF8A6D00),
    Color(0xFF15803D),
    Color(0xFFC2410C),
    Color(0xFF7E22CE),
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

  /// Neon frame colour for the cyber design; same name, same colour.
  static Color neonFor(String seed) =>
      neonTiles[_hash(seed) % neonTiles.length];

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
  static ThemeData get cyberDarkTheme => _build(cyberDark, Brightness.dark);
  static ThemeData get cyberLightTheme => _build(cyberLight, Brightness.light);
  static ThemeData get modernDarkTheme => _build(modernDark, Brightness.dark);
  static ThemeData get modernLightTheme => _build(modernLight, Brightness.light);

  static ThemeData _build(BoldPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.highlight,
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
      extensions: [_PaletteExt(p)],
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

/// Carries the active design palette in the [ThemeData], so widgets only need
/// [BoldTheme.of] instead of knowing which design is on.
class _PaletteExt extends ThemeExtension<_PaletteExt> {
  const _PaletteExt(this.palette);

  final BoldPalette palette;

  @override
  _PaletteExt copyWith({BoldPalette? palette}) =>
      _PaletteExt(palette ?? this.palette);

  @override
  _PaletteExt lerp(_PaletteExt? other, double t) => other ?? this;
}
