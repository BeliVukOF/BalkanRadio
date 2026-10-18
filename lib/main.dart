import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/radio_provider.dart';
import 'services/audio_handler.dart';
import 'ui/screens/region_selection_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await initAudioService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => RadioProvider(audioHandler: audioHandler),
      child: const BalkanRadioApp(),
    ),
  );
}

class BalkanRadioApp extends StatelessWidget {
  const BalkanRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadioProvider>();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.themeMode,
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RegionSelectionScreen(),
    );
  }
}
