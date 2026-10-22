import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/radio_provider.dart';
import 'services/update_service.dart';
import 'ui/bold/bold_home.dart';
import 'ui/bold/bold_theme.dart';
import 'ui/update_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the system bars; every screen adds its own SafeArea insets.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Nothing is awaited before runApp: the UI must appear even if audio
  // service start-up hangs, which is what froze the app on the splash screen.
  runApp(
    ChangeNotifierProvider(
      create: (_) => RadioProvider(),
      child: ChangeNotifierProvider(
        create: (_) => UpdateService(),
        child: const BalkanRadioApp(),
      ),
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
      'abstract' => (BoldTheme.abstractLightTheme, BoldTheme.abstractDarkTheme),
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
      supportedLocales: const [
        ...AppLocalizations.supportedLocales,
        // sr_Latn has no ARB of its own: it resolves to the Serbian strings by
        // languageCode and only routes Material tooltips to the Latin bundle.
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      ],
      // Transparent bars: with 3-button navigation Android otherwise paints an
      // opaque black slab under the app instead of showing its backdrop.
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        // Power saving: tell every animation (logo pulse, transitions) to stop.
        final reduceMotion = context.watch<RadioProvider>().prefs.isPowerSavingEnabled;
        final content = reduceMotion
            ? MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              )
            : child!;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
          ),
          child: content,
        );
      },
      home: const UpdateGate(child: BoldHome()),
    );
  }
}

/// Silent update check at start-up. The prompt waits for the first frame so it
/// cannot cover the splash screen, and fires only once per launch.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  bool _asked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_asked) return;
    _asked = true;
    final service = context.read<UpdateService>();
    await service.checkAtStartup();
    if (!mounted) return;
    if (service.available != null) {
      await showUpdateDialog(context, service);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
