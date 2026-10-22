import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/radio_station.dart';
import '../../providers/radio_provider.dart';
import 'abstract.dart';
import 'bold_theme.dart';

/// Paints the design background: gradient for Modern, grid for Cyberpunk,
/// nothing for Classic.
class NeonBackdrop extends StatelessWidget {
  const NeonBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    // Abstract: flat page plus the coral quarter disc in the top-right corner.
    if (palette.abstract) {
      return Stack(
        children: [
          const Positioned.fill(child: AbstractDecor()),
          Positioned.fill(child: child),
        ],
      );
    }
    final backdrop = palette.backdrop;
    if (backdrop != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: backdrop,
                ),
              ),
            ),
          ),
          child,
        ],
      );
    }
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
    this.gradient,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  /// Defaults to the palette's raised surface / body text.
  final Color? color;
  final Color? iconColor;
  final double iconSize;

  /// Filled gradient instead of a flat [color]; the Modern play buttons use it.
  final List<Color>? gradient;

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
        color: gradient == null ? (color ?? palette.surfaceHigh) : Colors.transparent,
        shape: palette.neon
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: framed
                    ? BorderSide(color: palette.frame?.top.color ?? palette.neonA)
                    : BorderSide.none,
              )
            : const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: gradient == null
              ? null
              : BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient!,
                  ),
                ),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Icon(icon, size: iconSize, color: iconColor ?? palette.text),
            ),
          ),
        ),
      ),
    );
    // Tooltip is announced as a description, not a name, so screen readers
    // still say "button". The same string is the control's label.
    final named =
        tooltip == null ? orb : Semantics(button: true, label: tooltip, child: orb);
    return tooltip == null ? named : Tooltip(message: tooltip!, child: named);
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
                    color: neonColor.withValues(alpha: 0.26),
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
                painter: RingsPainter(neonColor.withValues(alpha: 0.20)),
              ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: neonColor,
                  fontWeight: FontWeight.w800,
                  fontSize: size * (rings ? 0.22 : 0.30),
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
            CustomPaint(painter: RingsPainter(Colors.white.withValues(alpha: 0.10))),
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * (rings ? 0.22 : 0.30),
                letterSpacing: 0.5,
                // The Classic mock sets the monogram in a serif face.
                fontFamily: palette.modern ? null : 'serif',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gentle breathing scale for the player logo.
class PulseLogo extends StatefulWidget {
  const PulseLogo({super.key, required this.child});

  final Widget child;

  @override
  State<PulseLogo> createState() => _PulseLogoState();
}

class _PulseLogoState extends State<PulseLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(begin: 1, end: 1.035)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honour the system "remove animations" accessibility setting.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}


/// Equalizer bars for the player. They only move while a station plays, which
/// is the only honest signal the UI has for "audio is coming out".
class BoldEqualizer extends StatefulWidget {
  const BoldEqualizer({super.key, required this.active, this.color, this.height = 46, this.bars = 5});

  final bool active;
  final Color? color;
  final double height;
  final int bars;

  @override
  State<BoldEqualizer> createState() => _BoldEqualizerState();
}

class _BoldEqualizerState extends State<BoldEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant BoldEqualizer old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active && !MediaQuery.disableAnimationsOf(context)) {
      _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < widget.bars; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 6,
                  height: _barHeight(i),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Fixed wave shapes at different phases: without an audio tap this is a
  // stylised animation, not a real spectrum analyser.
  double _barHeight(int i) {
    final phase = _c.value * 2 * 3.14159265 + i * 0.9;
    final wave = (0.5 + 0.5 * _sin(phase)) * 0.72 + 0.28;
    final peak = widget.height * wave;
    final floor = widget.height * 0.28;
    if (peak < floor) return floor;
    return peak;
  }

  // dart:math sin without pulling the import into the whole file.
  double _sin(double x) => math.sin(x);
}

/// Fades and slightly lifts the child when the key changes, so switching
/// stations reads as a transition instead of a hard cut.
class CrossFade extends StatelessWidget {
  const CrossFade({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Scales and fades a page as it enters. Used for the player so opening it
/// feels like moving into the music instead of a hard cut.
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondary) => builder(context),
          transitionsBuilder: (context, animation, secondary, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
        );
}

/// Concentric rings of the player artwork, drawn on the tile or the card.
class RingsPainter extends CustomPainter {
  const RingsPainter(this.color, {this.count = 5, this.blur = 0});

  final Color color;

  /// How many rings; the Modern card shows three, the tile five.
  final int count;

  /// Soft edge in logical pixels; 0 keeps the crisp line of the other designs.
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;
    final center = Offset(size.width / 2, size.height / 2);
    final max = size.width * 0.5;
    for (var i = 1; i <= count; i++) {
      canvas.drawCircle(center, max * i / (count + 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RingsPainter old) =>
      old.color != color || old.count != count || old.blur != blur;
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

/// Chromatic-aberration title of the cyber design: cyan/magenta split on dark,
/// a single heavy offset on light. Shared by the home header and the player.
class GlitchTitle extends StatelessWidget {
  const GlitchTitle({
    super.key,
    required this.text,
    required this.palette,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 0.5,
    this.maxLines,
  });

  final String text;
  final BoldPalette palette;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: palette.text,
    );
    Widget layer(Color color, Offset offset) => Transform.translate(
          offset: offset,
          child: Text(
            text,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: style.copyWith(color: color),
          ),
        );
    final body = Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
    );
    if (palette.brightness == Brightness.light) {
      return Stack(
        children: [layer(palette.accent, const Offset(3, 3)), body],
      );
    }
    return Stack(
      children: [
        layer(palette.neonA, const Offset(-2.5, 1.5)),
        layer(palette.neonB, const Offset(2.5, -1.5)),
        body,
      ],
    );
  }
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
/// Screen readers need a name for the play control; the strings already
/// exist in every locale.
String _playLabel(AppLocalizations l10n, bool playing) =>
    playing ? l10n.contentDescriptionPause : l10n.contentDescriptionPlay;

class BoldStationRow extends StatelessWidget {
  const BoldStationRow({
    super.key,
    required this.station,
    required this.subtitle,
    required this.playing,
    required this.favorite,
    required this.last,
    required this.favoriteLabel,
    required this.onPlay,
    required this.onFavorite,
  });

  final RadioStation station;
  final String subtitle;
  final bool playing;
  final bool favorite;

  /// Last row: skip its separator so no stray line sits on the card edge.
  final bool last;
  final String favoriteLabel;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final l10n = AppLocalizations.of(context);
    if (palette.abstract) {
      final dark = palette.brightness == Brightness.dark;
      final row = InkWell(
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AbstractArtwork(name: station.name, size: 56, radius: 16),
              const SizedBox(width: 14),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                tooltip: favoriteLabel,
                size: 38,
                iconSize: 19,
                color: Colors.transparent,
                iconColor: favorite ? AbstractColors.coral : palette.textMuted,
                onPressed: onFavorite,
              ),
              const SizedBox(width: 6),
              Semantics(
                button: true,
                label: _playLabel(l10n, playing),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: dark ? AbstractColors.cream : AbstractColors.ink,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onPlay,
                      child: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 24,
                        color: dark ? AbstractColors.ink : AbstractColors.cream,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return Column(
        children: [
          row,
          if (!last)
            Divider(
              height: 1,
              thickness: 1,
              indent: 70,
              color: palette.surfaceHigh,
            ),
        ],
      );
    }
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
              Semantics(
                button: true,
                label: _playLabel(l10n, playing),
                child: NeonPlayButton(
                  icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 44,
                  onPressed: onPlay,
                ),
              )
            else
              BoldOrb(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                tooltip: _playLabel(l10n, playing),
                gradient: palette.playGradient,
                iconColor: palette.playGradient == null ? palette.accent : Colors.white,
                iconSize: 26,
                onPressed: onPlay,
              ),
          ],
        ),
      ),
    );

    if (palette.neon) {
      return Column(
        children: [
          row,
          if (!last) _DashedSeparator(palette.textMuted.withValues(alpha: 0.35)),
        ],
      );
    }
    if (!palette.modern) return row;
    return Column(
      children: [
        row,
        if (!last)
          Divider(height: 1, thickness: 1, color: palette.text.withValues(alpha: 0.12)),
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
    final l10n = AppLocalizations.of(context);
    // Abstract: solid blue card, the one saturated surface on the page.
    if (palette.abstract) {
      const cream = AbstractColors.cream;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Material(
          color: AbstractColors.blue,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  AbstractArtwork(name: station.name, size: 40, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: cream,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: cream,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              playing ? 'LIVE' : subtitle.toUpperCase(),
                              style: TextStyle(
                                color: cream.withValues(alpha: .85),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SleepChip(),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: _playLabel(l10n, playing),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Material(
                        color: cream,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onPlay,
                          child: Icon(
                            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 22,
                            color: AbstractColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.modern
              ? palette.glass
              : (palette.neon ? palette.surface : palette.surfaceHigh),
          border: palette.modern ? palette.glassFrame : palette.frame,
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
                        if (palette.neon || palette.modern)
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: palette.neon ? palette.neonB : palette.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                playing
                                    ? 'LIVE'
                                    : (palette.neon
                                        ? '// ${subtitle.toUpperCase()}'
                                        : subtitle.toUpperCase()),
                                style: TextStyle(
                                  color: palette.neon ? palette.neonB : palette.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: palette.neon ? 1.5 : 1,
                                  fontFamily: palette.neon ? 'monospace' : null,
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
                  const SleepChip(),
                  const SizedBox(width: 8),
                  if (palette.neon)
                    Semantics(
                      button: true,
                      label: _playLabel(l10n, playing),
                      child: NeonPlayButton(
                        icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 44,
                        onPressed: onPlay,
                      ),
                    )
                  else
                    BoldOrb(
                      icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      tooltip: _playLabel(l10n, playing),
                      gradient: palette.playGradient,
                      iconColor: palette.playGradient == null ? palette.accent : Colors.white,
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

  /// Abstract keeps the rounded set of its mock; every other design uses the
  /// outlined set so the four items read as one family, and settings gets a
  /// gear instead of a sun.
  static const List<IconData> _icons = [
    Icons.radio_outlined,
    Icons.public_outlined,
    Icons.favorite_border_rounded,
    Icons.settings_outlined,
  ];

  static const List<IconData> _abstractIcons = [
    Icons.radio_rounded,
    Icons.public_rounded,
    Icons.favorite_border_rounded,
    Icons.wb_sunny_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final icons = palette.abstract ? _abstractIcons : _icons;
    final row = Row(
      children: [for (var i = 0; i < labels.length; i++) _item(palette, i, icons)],
    );
    if (palette.abstract) {
      return SafeArea(
        top: false,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: palette.background,
            border: Border(top: BorderSide(color: palette.surfaceHigh)),
          ),
          child: row,
        ),
      );
    }
    if (!palette.modern) {
      // Cyber: the bar needs its own surface and a neon hairline, otherwise the
      // grid shows through the labels and the items read as one long word.
      return SafeArea(
        top: false,
        child: Container(
          height: palette.neon ? 70 : 62,
          decoration: BoxDecoration(
            color: palette.neon ? palette.background : null,
            border: palette.neon
                ? Border(
                    top: BorderSide(
                      color: palette.neonA.withValues(alpha: 0.35),
                    ),
                  )
                : null,
          ),
          child: row,
        ),
      );
    }
    // Modern: one floating glass pill, the active item in an outlined pill.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.glass,
            // Half of the 58px bar: the same curve family as the item pill.
            borderRadius: BorderRadius.circular(29),
            border: palette.glassFrame,
          ),
          child: SizedBox(height: 58, child: row),
        ),
      ),
    );
  }

  Widget _item(BoldPalette palette, int i, List<IconData> icons) => Expanded(
        child: Padding(
          // 6 horizontal + a 20px radius keeps the outlined pill clear of the
          // bar's own hairline border, even with four items.
          padding: palette.modern
              ? const EdgeInsets.symmetric(vertical: 5, horizontal: 6)
              : EdgeInsets.symmetric(horizontal: palette.neon ? 4 : 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              // 23 = half of the 46px item; a larger radius overflows the pill.
              borderRadius: BorderRadius.circular(palette.corners(20)),
              color: palette.modern && i == index
                  ? palette.highlight.withValues(alpha: 0.10)
                  : null,
              border: palette.modern && i == index
                  ? Border.all(
                      color: palette.highlight.withValues(alpha: 0.8),
                      width: 1.2,
                    )
                  : null,
            ),
            child: InkWell(
              onTap: () => onSelect(i),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (palette.abstract)
                          Container(
                            width: 48,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == index ? palette.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              icons[i],
                              size: 18,
                              color: i == index ? palette.onAccent : palette.text,
                            ),
                          )
                        else
                          Icon(
                            icons[i],
                            size: palette.neon ? 18 : 22,
                            color: i == index ? palette.highlight : palette.textMuted,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          palette.neon ? labels[i].toUpperCase() : labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: palette.neon ? 9 : 10.5,
                            letterSpacing: palette.neon ? 0.3 : 0,
                            fontFamily: palette.neon ? 'monospace' : null,
                            fontWeight: palette.neon || i == index
                                ? FontWeight.w700
                                : null,
                            color: palette.abstract
                                ? (i == index ? palette.text : palette.textMuted)
                                : (i == index ? palette.highlight : palette.textMuted),
                          ),
                        ),
                        if (palette.neon) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: i == index ? 18 : 0,
                            height: 2,
                            color: palette.highlight,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// "4:07" under an hour, "1h 05m" above: how much of the sleep timer is left.
String formatSleepRemaining(Duration left) => left.inHours > 0
    ? '${left.inHours}h ${(left.inMinutes % 60).toString().padLeft(2, '0')}m'
    : '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';

/// Remaining sleep-timer time, ticking once a second; invisible when unarmed.
class SleepChip extends StatefulWidget {
  const SleepChip({super.key});

  @override
  State<SleepChip> createState() => SleepChipState();
}

class SleepChipState extends State<SleepChip> {
  RadioProvider? _provider;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // No per-second wake-up while nothing is armed: the ticker only exists
    // between arming the sleep timer and cancelling it.
    _provider = context.read<RadioProvider>()..addListener(_syncTicker);
    _syncTicker();
  }

  void _syncTicker() {
    final armed = _provider?.sleepActive ?? false;
    if (armed && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!armed && _tick != null) {
      _tick!.cancel();
      _tick = null;
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_syncTicker);
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final left = context.watch<RadioProvider>().sleepRemaining;
    if (left == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(palette.corners(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bedtime_outlined, size: 14, color: palette.accent),
          const SizedBox(width: 6),
          Text(
            formatSleepRemaining(left),
            style: TextStyle(
              color: palette.accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
