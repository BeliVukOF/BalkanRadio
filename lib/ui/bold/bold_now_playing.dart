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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                        l10n.labelNowPlaying.toUpperCase(),
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                          letterSpacing: 2,
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final side = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight - 16,
                      );
                      return Center(
                        child: BoldMonogram(
                          name: station.name,
                          size: side,
                          radius: 40,
                          rings: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Align(alignment: Alignment.centerLeft, child: _LiveBadge()),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
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
                const SizedBox(height: 4),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BoldOrb(
                      icon: Icons.bedtime_outlined,
                      tooltip: l10n.labelSleepTimer,
                      size: 52,
                      iconSize: 24,
                      iconColor: provider.sleepActive ? palette.accent : palette.text,
                      onPressed: () => _pickSleepTimer(context, provider),
                    ),
                    BoldOrb(
                      icon: Icons.skip_previous_rounded,
                      size: 52,
                      iconSize: 26,
                      onPressed: () => _skip(provider, station, -1),
                    ),
                    BoldOrb(
                      icon: provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      tooltip: provider.isPlaying
                          ? l10n.contentDescriptionPause
                          : l10n.contentDescriptionPlay,
                      size: 78,
                      color: palette.accent,
                      iconColor: palette.onAccent,
                      iconSize: 40,
                      onPressed: provider.togglePlayPause,
                    ),
                    BoldOrb(
                      icon: Icons.skip_next_rounded,
                      size: 52,
                      iconSize: 26,
                      onPressed: () => _skip(provider, station, 1),
                    ),
                    BoldOrb(
                      icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      tooltip: favorite
                          ? l10n.contentDescriptionUnfavorite
                          : l10n.contentDescriptionFavorite,
                      size: 52,
                      iconSize: 26,
                      onPressed: () => _toggleFavorite(context, provider, station.streamUrl),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
    var closeApp = false;
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.labelSleepTimer,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(
                    l10n.sleepCloseApp,
                    style: TextStyle(color: palette.text, fontSize: 15),
                  ),
                  value: closeApp,
                  onChanged: (value) => setSheet(() => closeApp = value),
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
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE',
            style: TextStyle(
              color: palette.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
