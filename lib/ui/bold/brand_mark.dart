/// Brand mark: the "balkan radio" radio-wave symbol, drawn as vectors so it
/// stays crisp in every design and theme. Geometry is measured from the shipped
/// artwork (640px): dot r=35.5 at centre, arcs at r=102 and r=180, both stroked
/// 36 wide, i.e. dot radius = stroke width, arc radii = 2.9x and 5.1x the dot.
///
/// Colours come from the active [BoldPalette], never hardcoded: the logo was
/// drawn against the Bold dark theme (#FF6A45 accent on #0B1020), so reading
/// `palette.accent` keeps it on-brand in Cyberpunk, Modern and Abstract too.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bold_theme.dart';

/// Draws the brand symbol: an accent dot with two concentric quarter arcs
/// radiating up and to the right.
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({
    required this.color,
    required this.onColor,
  });

  final Color color;
  final Color onColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Proportions taken from the 640px master artwork.
    const dotR = 0.056; // 35.5 / 640
    const innerR = 0.159; // 101.9 / 640
    const outerR = 0.282; // 180.2 / 640
    const stroke = dotR * 2; // 36 / 640 measured

    final dot = Offset(size.width * 0.3755, size.height * 0.6211);
    final unit = math.min(size.width, size.height);

    canvas.drawCircle(dot, unit * dotR, Paint()..color = color);

    // Quarter arcs from straight-up round to straight-right: the symbol opens
    // to the top-right, exactly like the master artwork.
    final arcPaint = Paint()
      ..color = onColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * stroke
      ..strokeCap = StrokeCap.round;

    void arc(double r) {
      canvas.drawArc(
        Rect.fromCircle(center: dot, radius: unit * r),
        -math.pi / 2,
        math.pi / 2,
        false,
        arcPaint,
      );
    }

    arc(innerR);
    arc(outerR);
  }

  @override
  bool shouldRepaint(BrandMarkPainter old) =>
      old.color != color || old.onColor != onColor;
}

/// The brand symbol on its own, sized to [size].
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: BrandMarkPainter(
          color: palette.accent,
          onColor: palette.text,
        ),
      ),
    );
  }
}

/// The symbol plus the app name, for the header of the All stations screen.
///
/// [label] is the localised app name (`l10n.appName`) — the lockup never
/// hardcodes the wordmark, so it follows the system language like the rest of
/// the UI. Colours come from the active palette, so one widget serves every
/// design and both brightnesses.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    required this.label,
    this.markSize = 38,
    this.fontSize = 34,
  });

  final String label;
  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BrandMark(size: markSize),
        SizedBox(width: markSize * 0.32),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
      ],
    );
  }
}