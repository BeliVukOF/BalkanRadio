import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/radio_station.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../screens/settings_screen.dart';
import 'bold_now_playing.dart';
import 'bold_theme.dart';
import 'bold_widgets.dart';

/// "Bold" design shell: three tabs, mini player and full player on top of the
/// same RadioProvider the classic screens use.
class BoldHome extends StatefulWidget {
  const BoldHome({super.key});

  @override
  State<BoldHome> createState() => _BoldHomeState();
}

class _BoldHomeState extends State<BoldHome> {
  int _tab = 0;
  String? _region;
  bool _searching = false;
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Settings is the same screen as in the classic design, themed by the app.
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _toggleFavorite(RadioProvider provider, RadioStation station) async {
    try {
      await provider.toggleFavorite(station);
    } catch (error) {
      debugPrint('favourite failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).msgStorageError)),
      );
    }
  }

  Future<void> _play(RadioProvider provider, RadioStation station) async {
    if (provider.currentStation?.streamUrl == station.streamUrl) {
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
    final provider = context.watch<RadioProvider>();
    final l10n = AppLocalizations.of(context);
    final station = provider.currentStation;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: switch (_tab) {
                1 => _countries(provider, l10n),
                2 => _stations(provider, l10n, favoritesOnly: true),
                _ => _stations(provider, l10n, favoritesOnly: false),
              },
            ),
            if (station != null)
              BoldMiniPlayer(
                station: station,
                subtitle: regionLabel(l10n, station.region),
                playing: provider.isPlaying,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BoldNowPlaying()),
                ),
                onPlay: provider.togglePlayPause,
              ),
            BoldNavBar(
              index: _tab,
              labels: [l10n.titleAllStations, l10n.menuAllRegions, l10n.menuFavorites],
              onSelect: (index) => setState(() => _tab = index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, {required bool showSearch}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _searching
                    ? TextField(
                        controller: _search,
                        autofocus: true,
                        style: TextStyle(color: BoldTheme.of(context).text, fontSize: 20),
                        cursorColor: BoldTheme.of(context).accent,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          hintStyle: TextStyle(color: BoldTheme.of(context).textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: context.read<RadioProvider>().setSearchQuery,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            l10n.navHeaderSubtitle,
                            style: TextStyle(color: BoldTheme.of(context).textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.appName,
                            style: TextStyle(
                              color: BoldTheme.of(context).text,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
              ),
              if (showSearch)
                Column(
                  children: [
                    BoldOrb(
                      icon: Icons.settings_outlined,
                      tooltip: l10n.actionSettings,
                      size: 42,
                      onPressed: _openSettings,
                    ),
                    const SizedBox(height: 8),
                    BoldOrb(
                      icon: _searching ? Icons.close_rounded : Icons.search_rounded,
                      tooltip: _searching ? l10n.contentDescriptionClear : l10n.searchHint,
                      size: 42,
                      onPressed: () {
                        setState(() => _searching = !_searching);
                        if (!_searching) {
                          _search.clear();
                          context.read<RadioProvider>().setSearchQuery('');
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips(RadioProvider provider, AppLocalizations l10n) {
    final regions = provider.enabledRegions;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: l10n.titleAllStations,
            selected: _region == null,
            onTap: () => setState(() => _region = null),
          ),
          for (final region in regions)
            _Chip(
              label: regionLabel(l10n, region),
              selected: _region == region,
              onTap: () => setState(() => _region = region),
            ),
        ],
      ),
    );
  }

  Widget _stations(RadioProvider provider, AppLocalizations l10n, {required bool favoritesOnly}) {
    final stations = provider.getFilteredStations(
      region: favoritesOnly ? null : _region,
      isFavoritesOnly: favoritesOnly,
      regionLabeler: (region) => regionLabel(l10n, region),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(l10n, showSearch: true),
        const SizedBox(height: 12),
        if (!favoritesOnly) _chips(provider, l10n),
        const SizedBox(height: 8),
        if (provider.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: BoldTheme.of(context).accent,
            ),
          ),
        Expanded(
          child: stations.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      favoritesOnly ? l10n.favoritesEmpty : l10n.noStationsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BoldTheme.of(context).textMuted, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final current = provider.currentStation?.streamUrl == station.streamUrl;
                    final favorite = provider.prefs.isStationFavorite(station.streamUrl);
                    return BoldStationRow(
                      station: station,
                      subtitle: regionLabel(l10n, station.region),
                      playing: current && provider.isPlaying,
                      favorite: favorite,
                      favoriteLabel: favorite
                          ? l10n.contentDescriptionUnfavorite
                          : l10n.contentDescriptionFavorite,
                      onPlay: () => _play(provider, station),
                      onFavorite: () => _toggleFavorite(provider, station),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _countries(RadioProvider provider, AppLocalizations l10n) {
    final regions = provider.enabledRegions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(l10n, showSearch: false),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.45,
            children: [
              for (final region in regions)
                _CountryCard(
                  region: region,
                  label: regionLabel(l10n, region),
                  onTap: () => setState(() {
                    _region = region;
                    _tab = 0;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: selected ? BoldTheme.of(context).accent : BoldTheme.of(context).surfaceHigh,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? BoldTheme.of(context).onAccent : BoldTheme.of(context).text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  const _CountryCard({required this.region, required this.label, required this.onTap});

  final String region;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = BoldTheme.tileFor(region);
    return Material(
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tile,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BoldTheme.countryCodes[region] ?? region.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
