import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/radio_station.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../widgets/gradient_play_button.dart';
import '../widgets/mini_player.dart';
import '../widgets/station_avatar.dart';

class RadioListScreen extends StatefulWidget {
  const RadioListScreen({super.key, this.region, this.isFavoritesOnly = false});

  final String? region;
  final bool isFavoritesOnly;

  @override
  State<RadioListScreen> createState() => _RadioListScreenState();
}

class _RadioListScreenState extends State<RadioListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Every list screen starts unfiltered, wherever the user came from.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RadioProvider>().setSearchQuery('');
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    if (widget.isFavoritesOnly) return l10n.menuFavorites;
    final region = widget.region;
    if (region != null && region.isNotEmpty) return regionLabel(l10n, region);
    return l10n.titleAllStations;
  }

  Future<void> _play(RadioProvider provider, RadioStation station) async {
    if (provider.currentStation?.streamUrl == station.streamUrl && provider.isPlaying) {
      await provider.togglePlayPause();
      return;
    }
    final ok = await provider.playStation(station);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgPlayError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stations = provider.getFilteredStations(
      region: widget.region,
      isFavoritesOnly: widget.isFavoritesOnly,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: provider.setSearchQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.contentDescriptionClear,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          provider.setSearchQuery('');
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: scheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: scheme.primary),
                ),
                isDense: true,
              ),
            ),
          ),
          if (provider.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: stations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        widget.isFavoritesOnly && provider.searchQuery.isEmpty
                            ? l10n.favoritesEmpty
                            : l10n.noStationsFound,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      final isFavorite =
                          provider.prefs.isStationFavorite(station.streamUrl);
                      final isPlaying =
                          provider.currentStation?.streamUrl == station.streamUrl &&
                              provider.isPlaying;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: isPlaying
                              ? scheme.surfaceContainerHigh
                              : scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _play(provider, station),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                              child: Row(
                                children: [
                                  StationAvatar(
                                    name: station.name,
                                    active: isPlaying,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: isPlaying
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          regionLabel(l10n, station.region),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: scheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: isFavorite
                                        ? l10n.contentDescriptionUnfavorite
                                        : l10n.contentDescriptionFavorite,
                                    icon: Icon(
                                      isFavorite ? Icons.star : Icons.star_border,
                                      size: 22,
                                    ),
                                    color: isFavorite
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                    onPressed: () async {
                                      try {
                                        await provider.toggleFavorite(station);
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('$error')),
                                        );
                                      }
                                    },
                                  ),
                                  GradientPlayButton(
                                    size: 44,
                                    playing: isPlaying,
                                    active: isPlaying,
                                    label: isPlaying
                                        ? l10n.contentDescriptionPause
                                        : l10n.contentDescriptionPlay,
                                    onPressed: () => _play(provider, station),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
