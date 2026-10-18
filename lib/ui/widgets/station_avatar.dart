import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular monogram. The reference design uses album art; stations have none,
/// so the gradient ring carries the accent instead.
class StationAvatar extends StatelessWidget {
  const StationAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.active = false,
  });

  final String name;
  final double size;
  final bool active;

  static String initialsFor(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: active ? AppTheme.accent : null,
        color: active ? null : scheme.outline,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surface),
        child: Center(
          child: Text(
            initialsFor(name),
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: active ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
