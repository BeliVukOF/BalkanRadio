import 'package:flutter/material.dart';

import 'bold_theme.dart';

/// Flat Bauhaus artwork of the Abstract design. Every station gets a stable
/// composition: the name seeds which of the six palettes and which motif is
/// drawn, so covers never shuffle between launches.
class AbstractArtwork extends StatelessWidget {
  const AbstractArtwork({
    super.key,
    required this.name,
    required this.size,
    this.radius = 16,
    this.signal = false,
  });

  final String name;
  final double size;
  final double radius;

  /// Player artwork: the fixed "radio signal" composition of the mock (blue
  /// field, yellow and coral rings, cream core and a cream disc on the corner).
  final bool signal;

  static int _hash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final seed = _hash(name);
    final motif = seed % 6;
    if (signal) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AbstractColors.blue),
              Positioned(
                left: size * .17,
                top: size * .17,
                child: Container(
                  width: size * .66,
                  height: size * .66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AbstractColors.yellow,
                      width: size * .07,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: size * .30,
                top: size * .30,
                child: Container(
                  width: size * .40,
                  height: size * .40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AbstractColors.coral,
                      width: size * .07,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: size * .43,
                top: size * .43,
                child: Container(
                  width: size * .14,
                  height: size * .14,
                  decoration: const BoxDecoration(
                    color: AbstractColors.cream,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -size * .07,
                top: -size * .07,
                child: Container(
                  width: size * .26,
                  height: size * .26,
                  decoration: const BoxDecoration(
                    color: AbstractColors.cream,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(fit: StackFit.expand, children: _motif(motif, seed)),
      ),
    );
  }

  /// Eight colourways x six motifs: 48 combinations, so two stations in one
  /// list practically never get the same tile.
  static const List<List<Color>> _ways = [
    [AbstractColors.blue, AbstractColors.yellow, AbstractColors.coral],
    [AbstractColors.cream, AbstractColors.ink, AbstractColors.coral],
    [AbstractColors.green, AbstractColors.yellow, AbstractColors.ink],
    [AbstractColors.pink, AbstractColors.blue, AbstractColors.yellow],
    [AbstractColors.ink, AbstractColors.coral, AbstractColors.green],
    [AbstractColors.yellow, AbstractColors.blue, AbstractColors.ink],
    [AbstractColors.blue, AbstractColors.cream, AbstractColors.coral],
    [AbstractColors.coral, AbstractColors.cream, AbstractColors.ink],
  ];

  List<Widget> _motif(int motif, int seed) {
    final way = _ways[(seed ~/ 6) % _ways.length];
    final bg = way[0];
    final a = way[1];
    final b = way[2];
    final lightBg = bg.computeLuminance() > .5;
    const ink = AbstractColors.ink;
    const cream = AbstractColors.cream;

    Widget dot(Color color, double d, double x, double y) => Positioned(
          left: size * x,
          top: size * y,
          child: Container(
            width: size * d,
            height: size * d,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );

    Widget ring(Color color, double d, double x, double y, double w) =>
        Positioned(
          left: size * x,
          top: size * y,
          child: Container(
            width: size * d,
            height: size * d,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: size * w),
            ),
          ),
        );

    switch (motif) {
      case 0: // signal: rings
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          ring(a, .74, .13, .13, .055),
          ring(b, .46, .27, .27, .05),
          dot(lightBg ? ink : cream, .18, .41, .41),
        ];
      case 1: // sunset: sun over a dome
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          dot(a, .44, .28, .18),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size * .42,
            child: Container(
              decoration: BoxDecoration(
                color: lightBg ? ink : cream,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
              ),
            ),
          ),
          Positioned(
            left: size * .06,
            top: size * .06,
            child: Container(width: size * .18, height: size * .06, color: b),
          ),
        ];
      case 2: // mountain: triangle + sun
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          dot(a, .26, .58, .14),
          Positioned.fill(
            child: CustomPaint(painter: _TrianglePainter(lightBg ? ink : cream)),
          ),
          dot(b, .1, .12, .74),
        ];
      case 3: // diagonal stripe + dot
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          Positioned.fill(
            child: Transform.rotate(
              angle: -.7,
              child: Center(
                child: Container(width: size * 1.6, height: size * .22, color: a),
              ),
            ),
          ),
          dot(b, .24, .58, .6),
        ];
      case 4: // two quarters
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: size * .62,
              height: size * .62,
              decoration: BoxDecoration(
                color: a,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(999)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * .46,
              height: size * .46,
              decoration: BoxDecoration(
                color: b,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(999)),
              ),
            ),
          ),
          dot(lightBg ? ink : cream, .12, .44, .44),
        ];
      default: // target stripes
        return [
          Positioned.fill(child: ColoredBox(color: bg)),
          ring(a, .78, .11, .11, .07),
          ring(lightBg ? ink : cream, .5, .25, .25, .05),
          dot(b, .2, .4, .4),
        ];
    }
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .5, size.height * .38)
      ..lineTo(size.width * .95, size.height)
      ..lineTo(size.width * .05, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}

/// Brand decor of the Abstract design: a coral quarter disc bleeding out of the
/// top-right corner and a small blue dot beside it.
class AbstractDecor extends StatelessWidget {
  const AbstractDecor({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -w * .10,
              top: -w * .16,
              child: Container(
                width: w * .42,
                height: w * .42,
                decoration: const BoxDecoration(
                  color: AbstractColors.coral,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(999),
                  ),
                ),
              ),
            ),
            Positioned(
              right: w * .38,
              top: w * .13,
              child: Container(
                width: w * .07,
                height: w * .07,
                decoration: const BoxDecoration(
                  color: AbstractColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
