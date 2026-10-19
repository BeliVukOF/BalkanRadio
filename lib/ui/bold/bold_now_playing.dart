import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/radio_station.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import 'bold_theme.dart';
import 'bold_widgets.dart';

/// Next/previous land on the neighbouring station and wrap around.
int stepStationIndex(int index, int step, int length) =>
    length == 0 ? -1 : (((index < 0 ? 0 : index) + step) + length) % length;

/// Full-screen player of the "Bold" design: artwork, LIVE badge and controls.
class BoldNowPlaying extends StatelessWidget {
  const BoldNowPlaying({super.key});

  /// Durations offered by the sleep timer sheet.
  static const List<int> sleepChoices = [5, 10, 15, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadioProvider>();
    final l10n = AppLocalizations.of(context);
    final palette = BoldTheme.of(context);
    final station = provider.currentStation;
    final favorite = station != null && provider.prefs.isStationFavorite(station.streamUrl);

    return Scaffold(
      backgroundColor: palette.background,
      body: NeonBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              // Mocks: artwork ~38% of the height on the glass designs, and
              // the controls sit in thumb reach with empty space below instead
              // of hugging the system navigation bar.
              final artSide = math.min(
                box.maxWidth - 48,
                h * (box.maxWidth > box.maxHeight ? 0.18 : 0.38),
              );
              final bottomGap =
                  h * (palette.modern || palette.neon ? 0.13 : 0.05);
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
              Row(
                children: [
                  BoldOrb(
                    icon: Icons.keyboard_arrow_down_rounded,
                    tooltip: l10n.contentDescriptionBack,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        palette.neon
                            ? '// ${l10n.labelNowPlaying.toUpperCase()}'
                            : l10n.labelNowPlaying.toUpperCase(),
                        style: TextStyle(
                          color: palette.neon ? palette.neonA : palette.textMuted,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: palette.neon ? FontWeight.w700 : null,
                          fontFamily: palette.neon ? 'monospace' : null,
                        ),
                      ),
                    ),
                  ),
                  BoldOrb(
                    icon: Icons.stop_rounded,
                    tooltip: l10n.contentDescriptionStop,
                    onPressed: () {
                      provider.stop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              if (station == null)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.nowPlayingDefault,
                      style: TextStyle(color: palette.textMuted, fontSize: 16),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: artSide,
                  height: artSide,
                  child: _artwork(context, station, artSide),
                ),
                // Mock: a wider breath under the card before the info block.
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _LiveBadge(magenta: palette.neonB, neon: palette.neon),
                    const SleepChip(),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: palette.neon
                      ? GlitchTitle(
                          text: station.name.toUpperCase(),
                          palette: palette,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          maxLines: 2,
                        )
                      : Text(
                          station.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    regionLabel(l10n, station.region),
                    style: TextStyle(color: palette.textMuted, fontSize: 16),
                  ),
                ),
                if (provider.playbackError != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.error_outline, size: 18, color: palette.accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.msgPlaybackInterrupted,
                          style: TextStyle(color: palette.accent, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldOrb(
                      icon: Icons.bedtime_outlined,
                      tooltip: l10n.labelSleepTimer,
                      size: 52,
                      iconSize: 24,
                      color: palette.neon || palette.modern
                          ? Colors.transparent
                          : null,
                      iconColor: provider.sleepActive
                          ? palette.accent
                          : (palette.neon || palette.modern
                              ? palette.textMuted
                              : palette.text),
                      onPressed: () => _pickSleepTimer(context, provider),
                    ),
                    BoldOrb(
                      icon: Icons.skip_previous_rounded,
                      size: 52,
                      iconSize: 26,
                      color: palette.neon || palette.modern
                          ? Colors.transparent
                          : null,
                      onPressed: () => _skip(provider, station, -1),
                    ),
                    if (palette.neon)
                      NeonPlayButton(
                        icon: provider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 78,
                        cut: 18,
                        onPressed: provider.togglePlayPause,
                      )
                    else
                      BoldOrb(
                        icon: provider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        tooltip: provider.isPlaying
                            ? l10n.contentDescriptionPause
                            : l10n.contentDescriptionPlay,
                        size: 78,
                        color: palette.playGradient == null ? palette.accent : null,
                        gradient: palette.playGradient,
                        iconColor:
                            palette.playGradient == null ? palette.onAccent : Colors.white,
                        iconSize: 40,
                        onPressed: provider.togglePlayPause,
                      ),
                    BoldOrb(
                      icon: Icons.skip_next_rounded,
                      size: 52,
                      iconSize: 26,
                      color: palette.neon || palette.modern
                          ? Colors.transparent
                          : null,
                      onPressed: () => _skip(provider, station, 1),
                    ),
                    BoldOrb(
                      icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      tooltip: favorite
                          ? l10n.contentDescriptionUnfavorite
                          : l10n.contentDescriptionFavorite,
                      size: 52,
                      iconSize: 26,
                      color: palette.neon || palette.modern
                          ? Colors.transparent
                          : null,
                      iconColor: favorite
                          ? (palette.neon ? palette.neonB : palette.accent)
                          : (palette.neon
                              ? palette.neonB
                              : (palette.modern ? palette.accent : null)),
                      onPressed: () => _toggleFavorite(context, provider, station.streamUrl),
                    ),
                  ],
                ),
                SizedBox(height: bottomGap),
              ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Artwork block of the mock: rings on a frosted card for Modern, the
  /// gradient tile with rings for the other designs.
  Widget _artwork(BuildContext context, RadioStation station, double side) {
    final palette = BoldTheme.of(context);
    if (palette.modern) {
      return Container(
        decoration: BoxDecoration(
          color: palette.glass,
          borderRadius: BorderRadius.circular(40),
          border: palette.glassFrame,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: RingsPainter(
                  palette.text.withValues(alpha: 0.12),
                  count: 3,
                  blur: 3,
                ),
              ),
            ),
            Center(
              child: PulseLogo(
                child: BoldMonogram(
                  name: station.name,
                  // Mock: the logo circle is about a third of the card.
                  size: side * 0.34,
                  radius: side * 0.17,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return PulseLogo(
      child: BoldMonogram(
        name: station.name,
        size: side,
        radius: 40,
        rings: true,
      ),
    );
  }

  Future<void> _skip(RadioProvider provider, RadioStation current, int step) async {
    final stations = provider.getFilteredStations();
    if (stations.isEmpty) return;
    final index = stepStationIndex(
      stations.indexWhere((s) => s.streamUrl == current.streamUrl),
      step,
      stations.length,
    );
    await provider.playStation(stations[index]);
  }

  Future<void> _pickSleepTimer(BuildContext context, RadioProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final palette = BoldTheme.of(context);
    // The switch keeps whatever was chosen last time, not a reset default.
    var closeApp = provider.sleepClosesApp;
    final choice = await showModalBottomSheet<(Duration?, bool)>(
      context: context,
      backgroundColor: palette.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.labelSleepTimer,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SleepChip(),
                    ],
                  ),
                ),
                // Armed timer: cancel it right here, before picking a new one.
                if (provider.sleepActive)
                  ListTile(
                    leading: Icon(Icons.timer_off_outlined, color: palette.accent),
                    title: Text(l10n.sleepOff, style: TextStyle(color: palette.accent)),
                    onTap: () {
                      provider.setSleepTimer(null);
                      Navigator.pop(sheetContext);
                    },
                  ),
                SwitchListTile(
                  title: Text(
                    l10n.sleepCloseApp,
                    style: TextStyle(color: palette.text, fontSize: 15),
                  ),
                  value: closeApp,
                  onChanged: (value) {
                    setSheet(() => closeApp = value);
                    provider.setSleepCloseApp(value);
                  },
                ),
                for (final minutes in sleepChoices)
                  ListTile(
                    title: Text('$minutes min', style: TextStyle(color: palette.text)),
                    trailing: Icon(Icons.chevron_right, color: palette.textMuted),
                    onTap: () => Navigator.pop(
                      sheetContext,
                      (Duration(minutes: minutes), closeApp),
                    ),
                  ),
                if (!provider.sleepActive)
                  ListTile(
                    title: Text(l10n.sleepOff, style: TextStyle(color: palette.accent)),
                    onTap: () => Navigator.pop(sheetContext, (null, closeApp)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (choice == null) return;
    provider.setSleepTimer(choice.$1, closeApp: choice.$2);
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    RadioProvider provider,
    String streamUrl,
  ) async {
    try {
      final station = provider.allStations.firstWhere((s) => s.streamUrl == streamUrl);
      await provider.toggleFavorite(station);
    } catch (error) {
      debugPrint('favourite failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgStorageError)),
      );
    }
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({this.magenta, this.neon = false});

  final Color? magenta;
  final bool neon;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: neon
                    ? Colors.white
                    : (palette.modern ? palette.liveInk : palette.accent),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE',
            style: TextStyle(
              color: neon
                  ? Colors.white
                  : (palette.modern ? palette.liveInk : palette.text),
              fontSize: 13,
              fontWeight: neon ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: neon ? 2 : 1,
              fontFamily: neon ? 'monospace' : null,
            ),
          ),
        ],
      );
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: neon
            ? magenta
            : (palette.modern
                ? palette.liveInk.withValues(alpha: 0.18)
                : palette.surfaceHigh),
        borderRadius: BorderRadius.circular(palette.corners(20)),
      ),
      // Only the badge is slanted; the counter-skew keeps the label upright.
      child: neon
          ? Transform(transform: Matrix4.skewX(0.18), child: content)
          : content,
    );
    // Mock: the cyber badge is a slanted parallelogram, the others a pill.
    return neon ? Transform(transform: Matrix4.skewX(-0.18), child: badge) : badge;
  }
}
