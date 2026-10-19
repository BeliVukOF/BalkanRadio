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
      body: NeonBackdrop(
        child: SafeArea(
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
      ),
    );
  }

  /// Closing search leaves no query behind and drops the keyboard.
  void _closeSearch() {
    FocusScope.of(context).unfocus();
    _search.clear();
    context.read<RadioProvider>().setSearchQuery('');
    setState(() => _searching = false);
  }

  Widget _header(AppLocalizations l10n, {required bool showSearch}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // Mock: tapping the magnifier replaces the title with a back arrow
            // plus a full-width field — one cross-fade, no dead space.
            child: AnimatedSwitcher(
              // Power saving skips the cross-fade entirely.
              duration: context.read<RadioProvider>().prefs.isPowerSavingEnabled
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              // The default layout centres its child; keep both states left.
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, if (current != null) current],
              ),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.12, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _searching
                  ? Row(
                      key: const ValueKey('search'),
                      children: [
                        BoldOrb(
                          icon: Icons.arrow_back_rounded,
                          tooltip: l10n.contentDescriptionBack,
                          size: 46,
                          onPressed: _closeSearch,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SearchField(
                            controller: _search,
                            hint: l10n.searchHint,
                            onChanged: context.read<RadioProvider>().setSearchQuery,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('title'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        if (BoldTheme.of(context).neon) ...[
                          Text(
                            '// ${l10n.navHeaderSubtitle.toUpperCase()}',
                            style: TextStyle(
                              color: BoldTheme.of(context).neonA,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          GlitchTitle(
                            text: l10n.appName.toUpperCase(),
                            palette: BoldTheme.of(context),
                          ),
                        ] else ...[
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
                      ],
                    ),
            ),
          ),
          if (showSearch && !_searching) ...[
            const SizedBox(width: 12),
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
                  icon: Icons.search_rounded,
                  tooltip: l10n.searchHint,
                  size: 42,
                  onPressed: () => setState(() => _searching = true),
                ),
              ],
            ),
          ],
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
        if (!favoritesOnly && !_searching) _chips(provider, l10n),
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
              // The card is a fixed panel: it always fills the space between
              // the chips and the mini player, and the rows scroll inside it.
              : _listCard(
                    ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        BoldTheme.of(context).modern ? 14 : 20,
                        BoldTheme.of(context).modern ? 6 : 4,
                        BoldTheme.of(context).modern ? 14 : 20,
                        16,
                      ),
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
                          last: index == stations.length - 1,
                          favoriteLabel: favorite
                              ? l10n.contentDescriptionUnfavorite
                              : l10n.contentDescriptionFavorite,
                          onPlay: () => _play(provider, station),
                          onFavorite: () => _toggleFavorite(provider, station),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  /// Modern draws the station rows on one frosted card, like the mock.
  Widget _listCard(Widget list) {
    final palette = BoldTheme.of(context);
    if (!palette.modern) return list;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: palette.glass,
        borderRadius: BorderRadius.circular(28),
        border: palette.glassFrame,
      ),
      clipBehavior: Clip.antiAlias,
      child: list,
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
            childAspectRatio: 1.65,
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

/// Search box of the header: plain text for bold, framed field for cyber.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final field = TextField(
      controller: controller,
      autofocus: true,
      style: TextStyle(
        color: palette.text,
        fontSize: 18,
        fontFamily: palette.neon ? 'monospace' : null,
      ),
      cursorColor: palette.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.textMuted),
        border: InputBorder.none,
        isDense: true,
      ),
      onChanged: onChanged,
    );
    // Mock: glass pill for Modern, framed rectangle for Cyberpunk — the field
    // always has a body, never a bare line of text over the backdrop.
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.neon ? palette.surface : palette.glass,
        border: palette.neon ? palette.frame : null,
        borderRadius: BorderRadius.circular(palette.corners(23)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: palette.neon ? palette.neonA : palette.highlight,
          ),
          const SizedBox(width: 8),
          Expanded(child: field),
        ],
      ),
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
    final palette = BoldTheme.of(context);
    final gradient = selected ? palette.chipGradient : null;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // The border must follow the pill, otherwise its sharp corners show
          // as boxes around the rounded chip.
          borderRadius: BorderRadius.circular(palette.corners(22)),
          border: palette.neon && !selected
              ? Border.all(color: palette.frame!.top.color)
              : (palette.modern && !selected ? palette.glassFrame : null),
        ),
        child: Material(
          color: gradient != null
              ? Colors.transparent
              : (selected
                  ? palette.accent
                  : (palette.neon
                      ? Colors.transparent
                      : (palette.modern ? palette.glass : palette.surfaceHigh))),
          borderRadius: BorderRadius.circular(palette.corners(22)),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: gradient == null
                ? null
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                  ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    palette.neon ? label.toUpperCase() : label,
                    style: TextStyle(
                      color: gradient != null
                          ? Colors.white
                          : (selected ? palette.onAccent : palette.text),
                      fontWeight: palette.neon ? FontWeight.w700 : FontWeight.w600,
                      fontSize: palette.neon ? 13 : 15,
                      letterSpacing: palette.neon ? 1.5 : 0,
                      fontFamily: palette.neon ? 'monospace' : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "BALKAN RADIO" with the cyan/magenta split shadow of the cyber mock.
class _CountryCard extends StatelessWidget {
  const _CountryCard({required this.region, required this.label, required this.onTap});

  final String region;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final code = BoldTheme.countryCodes[region] ?? region.substring(0, 2).toUpperCase();
    final neon = palette.neon;
    final glass = palette.modern;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(palette.corners(26)),
        color: neon ? palette.surface : (glass ? palette.glass : null),
        border: glass ? palette.glassFrame : palette.frame,
        boxShadow: palette.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(palette.corners(26)),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: neon || glass
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: BoldTheme.tileFor(region),
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
                    code,
                    style: TextStyle(
                      color: neon
                          ? palette.highlight
                          : (glass ? palette.stationColor(region) : Colors.white),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: neon ? 2 : -0.5,
                      fontFamily: neon ? 'monospace' : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    neon ? label.toUpperCase() : label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: neon
                          ? palette.textMuted
                          : (glass ? palette.text : Colors.white),
                      fontSize: neon ? 13 : 16,
                      letterSpacing: neon ? 1.5 : 0,
                      fontFamily: neon ? 'monospace' : null,
                      fontWeight: neon ? FontWeight.w700 : FontWeight.w600,
                    ),
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
