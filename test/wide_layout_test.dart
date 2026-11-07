import 'package:balkan_radio/l10n/app_localizations.dart';
import 'package:balkan_radio/providers/radio_provider.dart';
import 'package:balkan_radio/ui/bold/bold_home.dart';
import 'package:balkan_radio/ui/bold/bold_theme.dart';
import 'package:balkan_radio/ui/bold/bold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A desktop browser window: 1920 x 1080 logical pixels.
const Size _wide = Size(1920, 1080);

void main() {
  late RadioProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '/tmp',
    );
    provider = RadioProvider();
  });

  tearDown(() {
    provider.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<RadioProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: BoldTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BoldHome(),
        ),
      ),
    );
    // The provider loads the station list asynchronously. A real delay is
    // needed: tester.pump() does not advance the pending future on its own.
    for (var i = 0; i < 80 && provider.allStations.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('a wide screen keeps the content in a readable column',
      (tester) async {
    await pumpApp(tester, size: _wide);

    final rows = find.byType(BoldStationRow);
    expect(rows, findsWidgets, reason: 'no stations were rendered');

    // The rows must not be stretched across the whole monitor: the text in
    // a row would end up unreadably far apart.
    final rect = tester.getRect(rows.first);
    expect(rect.width, lessThan(_wide.width),
        reason: 'the station row is wider than the screen');
    expect(rect.width, lessThanOrEqualTo(1100),
        reason: 'the station row is wider than the readable column');

    // The column is centred, so there is space on both sides.
    expect(rect.left, greaterThan(0));
    expect(rect.right, lessThan(_wide.width));
  });

  testWidgets('a phone is not affected by the wide-screen column',
      (tester) async {
    await pumpApp(tester, size: const Size(411, 914));

    final rows = find.byType(BoldStationRow);
    expect(rows, findsWidgets);
    final rect = tester.getRect(rows.first);
    expect(rect.width, lessThanOrEqualTo(411));
  });
}
