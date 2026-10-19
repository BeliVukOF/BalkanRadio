// TEMPORARY preview harness — not part of the app.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/radio_provider.dart';
import 'ui/bold/bold_home.dart';
import 'ui/bold/bold_now_playing.dart';
import 'ui/bold/bold_theme.dart';

void main() {
  final which = Uri.base.queryParameters['w'] ?? 'home';
  final theme =
      which == 'light' ? BoldTheme.abstractLightTheme : BoldTheme.abstractDarkTheme;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Theme(
        data: theme,
        child: ChangeNotifierProvider<RadioProvider>(
          create: (_) => RadioProvider(),
          child: which == 'player' ? const BoldNowPlaying() : const BoldHome(),
        ),
      ),
    ),
  );
}
