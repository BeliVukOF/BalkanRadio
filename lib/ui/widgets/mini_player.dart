import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../screens/now_playing_screen.dart';
import 'station_avatar.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final station = provider.currentStation;
    if (station == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            ),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                StationAvatar(
                  name: station.name,
                  size: 40,
                  active: provider.isPlaying,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: provider.isPlaying
                      ? l10n.contentDescriptionPause
                      : l10n.contentDescriptionPlay,
                  iconSize: 28,
                  icon: Icon(provider.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: provider.togglePlayPause,
                ),
                IconButton(
                  tooltip: l10n.contentDescriptionStop,
                  iconSize: 26,
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: provider.stop,
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
