import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_play_button.dart';
import '../widgets/station_avatar.dart';

/// Full-screen player, opened by tapping the mini player.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final station = provider.currentStation;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (station == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.nowPlayingDefault)),
      );
    }

    final isFavorite = provider.prefs.isStationFavorite(station.streamUrl);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: l10n.contentDescriptionBack,
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite
                ? l10n.contentDescriptionUnfavorite
                : l10n.contentDescriptionFavorite,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? scheme.primary : scheme.onSurfaceVariant,
            onPressed: () => provider.toggleFavorite(station),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.1,
            colors: [scheme.primary.withValues(alpha: 0.28), scheme.surface],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                _SpinningAvatar(
                  name: station.name,
                  playing: provider.isPlaying,
                  animate: !provider.prefs.isPowerSavingEnabled,
                ),
                const SizedBox(height: 36),
                Text(
                  station.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LiveBadge(active: provider.isPlaying),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        regionLabel(l10n, station.region),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: l10n.contentDescriptionStop,
                      iconSize: 32,
                      color: scheme.onSurfaceVariant,
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () {
                        provider.stop();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 24),
                    GradientPlayButton(
                      size: 80,
                      playing: provider.isPlaying,
                      buffering: provider.isBuffering,
                      label: provider.isPlaying
                          ? l10n.contentDescriptionPause
                          : l10n.contentDescriptionPlay,
                      onPressed: provider.togglePlayPause,
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      tooltip: isFavorite
                          ? l10n.contentDescriptionUnfavorite
                          : l10n.contentDescriptionFavorite,
                      iconSize: 32,
                      color: isFavorite ? scheme.primary : scheme.onSurfaceVariant,
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      onPressed: () => provider.toggleFavorite(station),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinningAvatar extends StatefulWidget {
  const _SpinningAvatar({
    required this.name,
    required this.playing,
    required this.animate,
  });

  final String name;
  final bool playing;
  final bool animate;

  @override
  State<_SpinningAvatar> createState() => _SpinningAvatarState();
}

class _SpinningAvatarState extends State<_SpinningAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldSpin = widget.playing && widget.animate;
    if (shouldSpin && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!shouldSpin && _spin.isAnimating) {
      _spin.stop();
    }

    final scheme = Theme.of(context).colorScheme;
    const size = 200.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _spin,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.playing ? AppTheme.accent : null,
                color: widget.playing ? null : scheme.outline,
              ),
            ),
          ),
          Container(
            width: size - 12,
            height: size - 12,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.surface),
            child: Text(
              StationAvatar.initialsFor(widget.name),
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: active ? AppTheme.accent : null,
        color: active ? null : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'LIVE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: active ? Colors.white : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
