import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular play control. The gradient ring marks the active station; idle rows
/// get a filled, muted button so the list keeps one clear focal point.
class GradientPlayButton extends StatelessWidget {
  const GradientPlayButton({
    super.key,
    required this.playing,
    required this.label,
    required this.onPressed,
    this.size = 48,
    this.active = true,
    this.buffering = false,
  });

  final bool playing;
  final String label;
  final VoidCallback onPressed;
  final double size;
  final bool active;
  final bool buffering;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
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
              color: active ? null : scheme.surfaceContainerHighest,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surface),
              child: Center(
                child: buffering
                    ? SizedBox(
                        width: size * 0.36,
                        height: size * 0.36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onSurface,
                        ),
                      )
                    : Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                        size: size * 0.5,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
