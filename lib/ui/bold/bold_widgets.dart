import 'package:flutter/material.dart';

import '../../models/radio_station.dart';
import 'bold_theme.dart';

/// Round button used for search, settings, play and favourite actions.
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
    final orb = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color ?? palette.surfaceHigh,
        shape: const CircleBorder(),
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

/// Rounded square with a two-letter monogram, coloured by the station name.
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

  /// Draws the concentric "on air" rings used on the player artwork.
  final bool rings;

  @override
  Widget build(BuildContext context) {
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
              BoldTheme.monogram(name),
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
    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(20),
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
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.textMuted, fontSize: 15),
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
              iconColor: favorite ? palette.accent : palette.textMuted,
              onPressed: onFavorite,
            ),
            const SizedBox(width: 8),
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
      child: Material(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(26),
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
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _icons[i],
                        size: 24,
                        color: i == index ? palette.accent : palette.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: i == index ? palette.accent : palette.textMuted,
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
