import 'package:flutter/material.dart';

import '../../models/radio_station.dart';
import 'bold_theme.dart';

/// Paints the cyber grid behind the screen; a no-op for the bold design.
class NeonBackdrop extends StatelessWidget {
  const NeonBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    if (!palette.neon) return child;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(palette.grid)),
        ),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);

  final Color color;

  static const double step = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.color != color;
}

/// Round button used for search, settings, play and favourite actions.
/// The cyber design turns it into a square with a neon frame.
class BoldOrb extends StatelessWidget {
  const BoldOrb({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 46,
    this.color,
    this.iconColor,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  /// Defaults to the palette's raised surface / body text.
  final Color? color;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    // Only the framed default button gets the neon border; a transparent one is
    // a bare icon (player controls).
    final framed = palette.neon && color == null;
    final orb = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color ?? palette.surfaceHigh,
        shape: palette.neon
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: framed
                    ? BorderSide(color: palette.frame?.top.color ?? palette.neonA)
                    : BorderSide.none,
              )
            : const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor ?? palette.text),
          ),
        ),
      ),
    );
    return tooltip == null ? orb : Tooltip(message: tooltip!, child: orb);
  }
}

/// Square with a two-letter monogram. Gradient tile for bold, neon frame for
/// the cyber design.
class BoldMonogram extends StatelessWidget {
  const BoldMonogram({
    super.key,
    required this.name,
    this.size = 56,
    this.radius = 18,
    this.rings = false,
  });

  final String name;
  final double size;
  final double radius;

  /// Draws the concentric rings used on the player artwork.
  final bool rings;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final neonColor = palette.stationColor(name);
    final label = BoldTheme.monogram(name);

    if (palette.neon) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: neonColor, width: 1.5),
          // Glow on dark, the hard offset shadow of the light mock otherwise.
          boxShadow: palette.brightness == Brightness.dark
              ? [
                  BoxShadow(
                    color: neonColor.withValues(alpha: 0.30),
                    blurRadius: 12,
                  ),
                ]
              : palette.shadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (rings)
              CustomPaint(
                painter: _RingsPainter(neonColor.withValues(alpha: 0.20)),
              ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: neonColor,
                  fontWeight: FontWeight.w800,
                  fontSize: size * (rings ? 0.26 : 0.30),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final tile = BoldTheme.tileFor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tile,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (rings)
            CustomPaint(painter: _RingsPainter(Colors.white.withValues(alpha: 0.10))),
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * (rings ? 0.26 : 0.30),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final max = size.width * 0.5;
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, max * i / 5.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.color != color;
}

/// Yellow action button with one cut corner, used by the cyber design.
class NeonPlayButton extends StatelessWidget {
  const NeonPlayButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 46,
    this.cut = 12,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double cut;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: _CutCornerClipper(cut),
        child: Material(
          color: palette.accent,
          child: InkWell(
            onTap: onPressed,
            child: Icon(icon, size: size * 0.52, color: palette.onAccent),
          ),
        ),
      ),
    );
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper(this.cut);

  final double cut;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - cut)
    ..lineTo(size.width - cut, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant _CutCornerClipper old) => old.cut != cut;
}

/// One dashed separator, the cyber design's row divider.
class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashPainter(color),
      );
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 0.5), Offset(x + 5, 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

/// One station line: avatar, name, region, favourite and play/pause.
class BoldStationRow extends StatelessWidget {
  const BoldStationRow({
    super.key,
    required this.station,
    required this.subtitle,
    required this.playing,
    required this.favorite,
    required this.favoriteLabel,
    required this.onPlay,
    required this.onFavorite,
  });

  final RadioStation station;
  final String subtitle;
  final bool playing;
  final bool favorite;
  final String favoriteLabel;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final row = InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(palette.corners(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BoldMonogram(name: station.name),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    palette.neon ? '// ${subtitle.toUpperCase()}' : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: palette.neon ? 13 : 15,
                      letterSpacing: palette.neon ? 1.2 : 0,
                      fontFamily: palette.neon ? 'monospace' : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            BoldOrb(
              icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              tooltip: favoriteLabel,
              size: 40,
              iconSize: 20,
              color: Colors.transparent,
              iconColor: favorite
                  ? (palette.neon ? palette.neonB : palette.accent)
                  : palette.textMuted,
              onPressed: onFavorite,
            ),
            const SizedBox(width: 8),
            if (palette.neon)
              NeonPlayButton(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44,
                onPressed: onPlay,
              )
            else
              BoldOrb(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                iconColor: palette.accent,
                iconSize: 26,
                onPressed: onPlay,
              ),
          ],
        ),
      ),
    );

    if (!palette.neon) return row;
    return Column(
      children: [
        row,
        _DashedSeparator(palette.textMuted.withValues(alpha: 0.35)),
      ],
    );
  }
}

/// Card above the navigation bar; tap opens the full player.
class BoldMiniPlayer extends StatelessWidget {
  const BoldMiniPlayer({
    super.key,
    required this.station,
    required this.subtitle,
    required this.playing,
    required this.onOpen,
    required this.onPlay,
  });

  final RadioStation station;
  final String subtitle;
  final bool playing;
  final VoidCallback onOpen;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.neon ? palette.surface : palette.surfaceHigh,
          border: palette.frame,
          boxShadow: palette.shadow,
          borderRadius: BorderRadius.circular(palette.corners(26)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(palette.corners(26)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  BoldMonogram(name: station.name, size: 48, radius: 16),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (palette.neon)
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: palette.neonB,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                playing ? 'LIVE' : '// ${subtitle.toUpperCase()}',
                                style: TextStyle(
                                  color: palette.neonB,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: palette.textMuted, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  if (palette.neon)
                    NeonPlayButton(
                      icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 44,
                      onPressed: onPlay,
                    )
                  else
                    BoldOrb(
                      icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      iconColor: palette.accent,
                      iconSize: 24,
                      onPressed: onPlay,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom bar: Stations / Countries / Favorites.
class BoldNavBar extends StatelessWidget {
  const BoldNavBar({
    super.key,
    required this.index,
    required this.labels,
    required this.onSelect,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  static const List<IconData> _icons = [
    Icons.radio_rounded,
    Icons.public_rounded,
    Icons.favorite_border_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Column(
                    children: [
                      if (palette.neon)
                        Container(
                          height: 2,
                          color: i == index ? palette.highlight : Colors.transparent,
                        ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _icons[i],
                              size: 24,
                              color: i == index ? palette.highlight : palette.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              palette.neon ? labels[i].toUpperCase() : labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: palette.neon ? 10 : 12,
                                letterSpacing: palette.neon ? 0.8 : 0,
                                fontFamily: palette.neon ? 'monospace' : null,
                                fontWeight: palette.neon ? FontWeight.w700 : null,
                                color: i == index ? palette.highlight : palette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
