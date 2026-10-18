import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular play control. The gradient ring marks the station that is playing;
/// idle rows keep a muted ring so the list has one clear focal point.
class GradientPlayButton extends StatelessWidget {
  const GradientPlayButton({
    super.key,
    required this.playing,
    required this.label,
    required this.onPressed,
    this.size = 48,
    this.active = true,
  });

  final bool playing;
  final String label;
  final VoidCallback onPressed;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: onPressed,
          radius: size / 2,
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: active ? AppTheme.accent : null,
              color: active ? null : scheme.outlineVariant,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surface),
              child: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
