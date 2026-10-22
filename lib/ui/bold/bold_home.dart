import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/radio_station.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../screens/settings_screen.dart';
import 'bold_now_playing.dart';
import 'abstract.dart';
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
  final TextEditingController _search = TextEditingController();

  bool _playerOpen = false;

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
    // Captured before the await: playStation notifies listeners and this widget
    // can rebuild, which deactivates the element a later context lookup uses.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failureText = AppLocalizations.of(context).msgPlayError;
    final ok = await provider.playStation(station);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(failureText)));
      return;
    }
    if (provider.prefs.autoOpenPlayer) _openPlayer(navigator);
  }

  /// The full-screen player. Pushed once: a second tap while it is open would
  /// stack copies. The station rows are not inside a route of their own, so
  /// ModalRoute.of(context) is null here and cannot be used as a guard.
  void _openPlayer(NavigatorState navigator) {
    if (_playerOpen) return;
    _playerOpen = true;
    navigator
        .push(FadeThroughPageRoute<void>(builder: (_) => const BoldNowPlaying()))
        .whenComplete(() => _playerOpen = false);
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
              labels: [
                l10n.titleAllStations,
                l10n.menuAllRegions,
                l10n.menuFavorites,
                l10n.titleSettings,
              ],
              onSelect: (index) {
                // Fourth slot is settings in every design.
                if (index == 3) {
                  _openSettings();
                  return;
                }
                setState(() => _tab = index);
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, {required bool showSearch}) {
    final palette = BoldTheme.of(context);
    final abstract = palette.abstract;
    final rawEyebrow = abstract ? l10n.appName : l10n.navHeaderSubtitle;
    final eyebrow = palette.neon ? '// ${rawEyebrow.toUpperCase()}' : rawEyebrow;
    final title = switch (_tab) {
      1 => l10n.menuAllRegions,
      2 => l10n.menuFavorites,
      _ => abstract ? l10n.titleAllStations : l10n.appName,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(abstract ? 20 : 20, abstract ? 18 : 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            abstract ? eyebrow.toUpperCase() : eyebrow,
            style: TextStyle(
              color: palette.neon ? palette.neonA : palette.textMuted,
              fontSize: abstract ? 11 : (palette.neon ? 12 : 13),
              fontWeight: palette.neon || abstract ? FontWeight.w700 : null,
              letterSpacing: abstract ? 2.2 : (palette.neon ? 2.5 : 0),
              fontFamily: palette.neon ? 'monospace' : null,
            ),
          ),
          const SizedBox(height: 6),
          if (palette.neon)
            GlitchTitle(
              text: title.toUpperCase(),
              palette: palette,
              fontSize: 28,
            )
          else
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            _SearchField(
              controller: _search,
              hint: l10n.searchHint,
              onChanged: context.read<RadioProvider>().setSearchQuery,
              autofocus: false,
            ),
          ],
          const SizedBox(height: 12),
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
                    padding: const EdgeInsets.all(24),
                    child: BoldTheme.of(context).abstract && favoritesOnly
                        ? _abstractEmptyFavorites(l10n)
                        : Text(
                            favoritesOnly ? l10n.favoritesEmpty : l10n.noStationsFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: BoldTheme.of(context).textMuted,
                              fontSize: 16,
                            ),
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
                        return StaggeredRow(
                          index: index,
                          child: BoldStationRow(
                            station: station,
                            subtitle: regionLabel(l10n, station.region),
                            playing: current && provider.isPlaying,
                            favorite: favorite,
                            last: index == stations.length - 1,
                            favoriteLabel: favorite
                                ? l10n.contentDescriptionUnfavorite
                                : l10n.contentDescriptionFavorite,
                            onPlay: () => _play(provider, station),
                            onFavorite: () =>
                                _toggleFavorite(provider, station),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  /// Modern draws the station rows on one frosted card, like the mock.
  /// Favourites, empty: the dashed hint card of the mock.
  Widget _abstractEmptyFavorites(AppLocalizations l10n) {
    final palette = BoldTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.textMuted.withValues(alpha: .6),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AbstractColors.green),
                  Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AbstractColors.pink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.favoritesEmpty,
              style: TextStyle(color: palette.text, fontSize: 14, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

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
    this.autofocus = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  /// The field now lives in the header permanently, so it must not grab focus
  /// on launch and pop the keyboard.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final palette = BoldTheme.of(context);
    final field = TextField(
      controller: controller,
      autofocus: autofocus,
      style: TextStyle(
        color: palette.text,
        // Neon is monospace and roomy: 18px cuts the hint off at the frame.
        fontSize: palette.neon ? 14 : 17,
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
    if (palette.abstract) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: selected ? palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: selected
                    ? null
                    : Border.all(color: palette.text.withValues(alpha: .35)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? palette.onAccent : palette.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }
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
                padding: EdgeInsets.symmetric(
                  horizontal: palette.neon ? 14 : 20,
                ),
                child: Center(
                  child: Text(
                    palette.neon ? label.toUpperCase() : label,
                    style: TextStyle(
                      color: gradient != null
                          ? Colors.white
                          : (selected ? palette.onAccent : palette.text),
                      fontWeight: palette.neon ? FontWeight.w700 : FontWeight.w600,
                      fontSize: palette.neon ? 12 : 14,
                      letterSpacing: palette.neon ? 1 : 0,
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
    if (palette.abstract) {
      return LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  // Square art, cropped by the tile: keeps the motif readable.
                  Positioned(
                    left: 0,
                    top: 0,
                    child: AbstractArtwork(name: region, size: w, radius: 0),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 6, 14, 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(999),
                        ),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AbstractColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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
