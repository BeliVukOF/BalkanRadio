import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/radio_provider.dart';
import 'ui/bold/bold_home.dart';
import 'ui/bold/bold_theme.dart';
import 'ui/screens/region_selection_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Nothing is awaited before runApp: the UI must appear even if audio
  // service start-up hangs, which is what froze the app on the splash screen.
  runApp(
    ChangeNotifierProvider(
      create: (_) => RadioProvider(),
      child: const BalkanRadioApp(),
    ),
  );
}

class BalkanRadioApp extends StatelessWidget {
  const BalkanRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadioProvider>();
    // Each design has its own light and dark palette; the theme choice picks one.
    final bold = provider.design == 'bold';

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: bold ? BoldTheme.lightTheme : AppTheme.light,
      darkTheme: bold ? BoldTheme.darkTheme : AppTheme.dark,
      themeMode: provider.themeMode,
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: bold ? const BoldHome() : const RegionSelectionScreen(),
    );
  }
}
