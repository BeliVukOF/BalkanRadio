import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import 'legal_screen.dart';

/// Kept in sync with pubspec.yaml by a unit test (`about version matches pubspec`).
const String appVersion = '1.3.7';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleSettings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Edge-to-edge: the list must stop above the system navigation bar
      // (3-button and gesture modes both), not scroll underneath it.
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
          _Section(
            title: l10n.titleAppearance,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.labelTheme),
                subtitle: Text(_themeLabel(l10n, provider.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTheme(context, provider),
              ),
            ],
          ),
          _Section(
            title: l10n.titleDesign,
            children: [
              for (final option in const ['classic', 'modern', 'cyber'])
                ListTile(
                  leading: Icon(switch (option) {
                    'classic' => Icons.palette_outlined,
                    'modern' => Icons.bolt_outlined,
                    _ => Icons.grid_on,
                  }),
                  title: Text(switch (option) {
                    'classic' => l10n.designClassic,
                    'modern' => l10n.designModern,
                    _ => l10n.designCyber,
                  }),
                  trailing: provider.design == option ? const Icon(Icons.check) : null,
                  onTap: () => _guard(context, () => provider.setDesign(option)),
                ),
            ],
          ),
          _Section(
            title: l10n.titleLanguage,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l10n.labelSelectLanguage),
                subtitle: Text(_languageLabel(l10n, provider.prefs.appLanguage)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLanguage(context, provider),
              ),
            ],
          ),
          _Section(
            title: l10n.titleEnabledRegions,
            children: [
              for (final region in provider.availableRegions)
                SwitchListTile(
                  title: Text(regionLabel(l10n, region)),
                  value: provider.prefs.isRegionEnabled(region),
                  onChanged: (value) async {
                    final ok = await _guard(
                      context,
                      () => provider.setRegionEnabled(region, value),
                    );
                    if (ok == false && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.msgKeepOneRegion)),
                      );
                    }
                  },
                ),
            ],
          ),
          _Section(
            title: l10n.titlePerformance,
            children: [
              SwitchListTile(
                title: Text(l10n.labelPowerSaving),
                subtitle: Text(l10n.descPowerSaving),
                value: provider.prefs.isPowerSavingEnabled,
                onChanged: (value) =>
                    _guard(context, () => provider.setPowerSavingEnabled(value)),
              ),
            ],
          ),
          _Section(
            title: l10n.titleContent,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l10n.labelRefreshStations),
                subtitle: Text(l10n.descRefreshStations),
                onTap: () async {
                  final refreshed = await provider.loadStations();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        refreshed
                            ? l10n.msgStationsUpdated(provider.allStations.length)
                            : l10n.msgStationsUpdateFailed,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          _Section(
            title: l10n.titleLegal,
            children: [
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
            ],
          ),
          _Section(
            title: l10n.titleAbout,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.navHeaderSubtitle),
                subtitle: Text(l10n.aboutVersion(appVersion)),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  /// Settings must never fail silently: any storage error is shown to the user.
  Future<T?> _guard<T>(BuildContext context, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      // Log the real cause, show a translated message: never leak internals.
      debugPrint('settings write failed: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).msgStorageError)),
        );
      }
      return null;
    }
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

  static String _languageLabel(AppLocalizations l10n, String code) => switch (code) {
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
              selected: mode == provider.themeMode,
              trailing: mode == provider.themeMode ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(dialogContext, mode),
            ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      await _guard(context, () => provider.setThemeMode(selected));
    }
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
              selected: code == provider.prefs.appLanguage,
              trailing:
                  code == provider.prefs.appLanguage ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(dialogContext, code),
            ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      await _guard(context, () => provider.setAppLanguage(selected));
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 6, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Material(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 16, color: scheme.outlineVariant),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
