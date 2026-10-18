import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/gradient_play_button.dart';
import '../widgets/mini_player.dart';
import '../widgets/station_avatar.dart';
import 'radio_list_screen.dart';
import 'settings_screen.dart';

class RegionSelectionScreen extends StatelessWidget {
  const RegionSelectionScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final station = provider.currentStation;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    tooltip: l10n.navigationDrawerOpen,
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.actionSettings,
                  icon: const Icon(Icons.tune),
                  onPressed: () => _open(context, const SettingsScreen()),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: theme.brightness == Brightness.dark
                    ? AppTheme.heroDark
                    : AppTheme.heroLight,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (station != null)
                        StationAvatar(name: station.name, size: 64, active: provider.isPlaying)
                      else
                        const Icon(Icons.radio, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station?.name ?? l10n.appName,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              station == null
                                  ? l10n.navHeaderSubtitle
                                  : regionLabel(l10n, station.region),
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GradientPlayButton(
                        size: 52,
                        playing: provider.isPlaying,
                        label: provider.isPlaying
                            ? l10n.contentDescriptionPause
                            : l10n.contentDescriptionPlay,
                        onPressed: provider.togglePlayPause,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.star,
              label: l10n.menuFavorites,
              onTap: () => _open(context, const RadioListScreen(isFavoritesOnly: true)),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.podcasts,
              label: l10n.menuAllRegions,
              onTap: () => _open(context, const RadioListScreen()),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.titleChooseRegion,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final region in provider.enabledRegions)
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.surfaceContainer,
                      foregroundColor: scheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _open(context, RadioListScreen(region: region)),
                    child: Text(regionLabel(l10n, region)),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: AppTheme.accent),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
