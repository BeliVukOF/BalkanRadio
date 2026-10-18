import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/radio_provider.dart';
import '../region_labels.dart';
import '../screens/radio_list_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<RadioProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.radio, size: 48, color: scheme.onPrimaryContainer),
                const SizedBox(height: 12),
                Text(
                  l10n.navHeaderTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  l10n.navHeaderSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(l10n.menuAllRegions),
            onTap: () => _open(context, const RadioListScreen()),
          ),
          ListTile(
            leading: Icon(Icons.star, color: scheme.primary),
            title: Text(l10n.menuFavorites),
            onTap: () => _open(context, const RadioListScreen(isFavoritesOnly: true)),
          ),
          const Divider(),
          for (final region in provider.enabledRegions)
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(regionLabel(l10n, region)),
              onTap: () => _open(context, RadioListScreen(region: region)),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.menuSettings),
            onTap: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }
}
