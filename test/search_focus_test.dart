import 'package:balkan_radio/data/station_repository.dart';
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

/// The search field must survive the keyboard.
///
/// The bug: the header picked its layout from the height that was left over
/// (`box.maxHeight < 520`). When the keyboard opened, the height shrank, the
/// header switched from a column to a row, and the search field moved to
/// another place in the tree. Flutter threw the old element away, the field
/// lost its focus, and the keyboard closed itself the moment it opened. The
/// same switch also made the row too narrow, so the field overflowed.
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

  Future<void> pumpApp(WidgetTester tester, {required Size size}) async {
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
    // The station list loads asynchronously. A real delay is needed:
    // tester.pump() does not advance the pending future on its own.
    for (var i = 0; i < 80 && provider.allStations.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('the search field keeps the focus when the keyboard opens',
      (tester) async {
    await pumpApp(tester, size: const Size(377, 831));

    final field = find.byType(TextField);
    expect(field, findsOneWidget, reason: 'no search field');

    // The user taps the field: the keyboard opens.
    await tester.tap(field);
    await tester.pump();
    expect(
      tester.testTextInput.hasAnyClients,
      isTrue,
      reason: 'the keyboard did not open when the field was tapped',
    );

    // The keyboard takes about half of the screen.
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The field must still be there and still be focused.
    expect(find.byType(TextField), findsOneWidget,
        reason: 'the search field was removed when the keyboard opened');
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue,
        reason: 'the search field lost the focus when the keyboard opened');
    expect(
      tester.testTextInput.hasAnyClients,
      isTrue,
      reason: 'the keyboard closed itself when the keyboard opened',
    );

    // And the text can still be typed into it.
    await tester.enterText(field, 'radio');
    await tester.pump();
    expect(find.text('radio'), findsWidgets);
  });

  testWidgets('the search field is not rebuilt when the keyboard opens',
      (tester) async {
    await pumpApp(tester, size: const Size(377, 831));

    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.pump();
    expect(tester.testTextInput.hasAnyClients, isTrue);

    // The element must be the same one: that is what keeps the focus.
    final before = tester.element(find.byType(EditableText));
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final after = tester.element(find.byType(EditableText));
    expect(
      identical(before, after),
      isTrue,
      reason: 'the search field was rebuilt when the keyboard opened',
    );
  });

  testWidgets('the header does not overflow when the keyboard is open',
      (tester) async {
    await pumpApp(tester, size: const Size(377, 831));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // A RenderFlex that overflows is reported as a test failure.
    expect(tester.takeException(), isNull,
        reason: 'the header overflows when the keyboard is open');
  });

  testWidgets('the station list is filtered by the search', (tester) async {
    await pumpApp(tester, size: const Size(377, 831));
    final station = StationRepository.allStations.first;

    await tester.enterText(find.byType(TextField), station.name);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byType(BoldStationRow),
      findsWidgets,
      reason: 'the list did not show the searched station',
    );
  });
}
