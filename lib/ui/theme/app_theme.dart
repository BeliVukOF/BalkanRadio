import 'package:flutter/material.dart';

/// One seed for both schemes plus an explicit surface ramp, so the app keeps the
/// deep-navy look in dark mode and stays readable in light mode.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF6C5CE7);

  /// Accent used only for decorative rings; never for text.
  static const LinearGradient accent = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFFFF9E3D), Color(0xFFB44BFF)],
  );

  static const LinearGradient heroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A1B4D), Color(0xFF17172A)],
  );

  static const LinearGradient heroLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF9B8CFF)],
  );

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final scheme = brightness == Brightness.dark
        ? base.copyWith(
            surface: const Color(0xFF12121F),
            surfaceContainerLowest: const Color(0xFF0C0C16),
            surfaceContainerLow: const Color(0xFF17172A),
            surfaceContainer: const Color(0xFF1D1D33),
            surfaceContainerHigh: const Color(0xFF242440),
            surfaceContainerHighest: const Color(0xFF2C2C4A),
            onSurface: const Color(0xFFEDEDF7),
            onSurfaceVariant: const Color(0xFFAFAFCA),
            outlineVariant: const Color(0xFF3A3A5C),
          )
        : base.copyWith(
            surface: const Color(0xFFF7F6FB),
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: Colors.white,
            surfaceContainer: const Color(0xFFEFEDF7),
            surfaceContainerHigh: const Color(0xFFE6E3F2),
            surfaceContainerHighest: const Color(0xFFDCD8EC),
            onSurface: const Color(0xFF14142B),
            onSurfaceVariant: const Color(0xFF4F4F68),
            outlineVariant: const Color(0xFFC9C5DC),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    );
  }
}
