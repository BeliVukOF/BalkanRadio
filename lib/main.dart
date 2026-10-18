import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/radio_provider.dart';
import 'ui/bold/bold_home.dart';
import 'ui/bold/bold_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the system bars; every screen adds its own SafeArea insets.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    final (light, dark) = switch (provider.design) {
      'modern' => (BoldTheme.modernLightTheme, BoldTheme.modernDarkTheme),
      'cyber' => (BoldTheme.cyberLightTheme, BoldTheme.cyberDarkTheme),
      _ => (BoldTheme.lightTheme, BoldTheme.darkTheme),
    };

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: provider.themeMode,
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Transparent bars: with 3-button navigation Android otherwise paints an
      // opaque black slab under the app instead of showing its backdrop.
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
          ),
          child: child!,
        );
      },
      home: const BoldHome(),
    );
  }
}
