import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../widgets/mini_player.dart';
import 'legal_screen.dart';

// shortcut: version duplicated from pubspec.yaml, move to package_info_plus if it drifts.
const String _appVersion = '1.1.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _SectionHeader(l10n.titleAppearance),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.labelTheme),
            subtitle: Text(_themeLabel(l10n, provider.themeMode)),
            onTap: () => _pickTheme(context, provider),
          ),

          _SectionHeader(l10n.titleLanguage),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.labelSelectLanguage),
            subtitle: Text(_languageLabel(l10n, provider.prefs.appLanguage)),
            onTap: () => _pickLanguage(context, provider),
          ),

          _SectionHeader(l10n.titleEnabledRegions),
          for (final region in provider.availableRegions)
            SwitchListTile(
              title: Text(regionLabel(l10n, region)),
              value: provider.prefs.isRegionEnabled(region),
              onChanged: (value) async {
                final ok = await provider.setRegionEnabled(region, value);
                if (!ok && context.mounted) {
                  _snack(context, l10n.msgKeepOneRegion);
                }
              },
            ),

          _SectionHeader(l10n.titlePerformance),
          SwitchListTile(
            title: Text(l10n.labelPowerSaving),
            subtitle: Text(l10n.descPowerSaving),
            value: provider.prefs.isPowerSavingEnabled,
            onChanged: provider.setPowerSavingEnabled,
          ),

          _SectionHeader(l10n.titleContent),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.labelRefreshStations),
            subtitle: Text(l10n.descRefreshStations),
            onTap: () async {
              final refreshed = await provider.loadStations();
              if (!context.mounted) return;
              _snack(
                context,
                refreshed
                    ? l10n.msgStationsUpdated(provider.allStations.length)
                    : l10n.msgStationsUpdateFailed,
              );
            },
          ),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openLegal(context, l10n.privacyPolicy, l10n.privacyBody),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openLegal(context, l10n.termsOfService, l10n.termsBody),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.titleAbout),
            subtitle: Text(l10n.aboutVersion(_appVersion)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.navHeaderSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openLegal(BuildContext context, String title, String body) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LegalScreen(title: title, body: body)),
    );
  }

  static String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
        ThemeMode.system => l10n.themeSystem,
      };

  static String _languageLabel(AppLocalizations l10n, String code) =>
      switch (code) {
        'system' => l10n.languageSystem,
        'sr' => l10n.langSerbian,
        'bs' => l10n.langBosnian,
        'hr' => l10n.langCroatian,
        'cnr' => l10n.langMontenegrin,
        'mk' => l10n.langMacedonian,
        'sq' => l10n.langAlbanian,
        'bg' => l10n.langBulgarian,
        'el' => l10n.langGreek,
        _ => l10n.langEnglish,
      };

  Future<void> _pickTheme(BuildContext context, RadioProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.labelTheme),
        children: [
          for (final mode in ThemeMode.values)
            ListTile(
              title: Text(_themeLabel(l10n, mode)),
              trailing: mode == provider.themeMode
                  ? const Icon(Icons.check, semanticLabel: 'selected')
                  : null,
              onTap: () => Navigator.pop(dialogContext, mode),
            ),
        ],
      ),
    );
    if (selected != null) await provider.setThemeMode(selected);
  }

  Future<void> _pickLanguage(BuildContext context, RadioProvider provider) async {
    final l10n = AppLocalizations.of(context);
    const codes = ['system', 'en', 'sr', 'bs', 'hr', 'cnr', 'mk', 'sq', 'bg', 'el'];
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.labelSelectLanguage),
        children: [
          for (final code in codes)
            ListTile(
              title: Text(_languageLabel(l10n, code)),
              trailing: code == provider.prefs.appLanguage
                  ? const Icon(Icons.check, semanticLabel: 'selected')
                  : null,
              onTap: () => Navigator.pop(dialogContext, code),
            ),
        ],
      ),
    );
    if (selected != null) await provider.setAppLanguage(selected);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
