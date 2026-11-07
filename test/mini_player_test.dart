import 'package:balkan_radio/l10n/app_localizations.dart';
import 'package:balkan_radio/models/radio_station.dart';
import 'package:balkan_radio/providers/radio_provider.dart';
import 'package:balkan_radio/ui/bold/bold_theme.dart';
import 'package:balkan_radio/ui/bold/bold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real phone in portrait: 377 x 831 logical pixels.
const Size _phone = Size(377, 831);

const _designs = ['classic', 'modern', 'cyber', 'abstract'];

ThemeData _themeFor(String design) => switch (design) {
      'modern' => BoldTheme.modernDarkTheme,
      'cyber' => BoldTheme.cyberDarkTheme,
      'abstract' => BoldTheme.abstractDarkTheme,
      _ => BoldTheme.darkTheme,
    };

const _station = RadioStation(
  name: 'Play Radio',
  streamUrl: 'https://example.com/play',
  region: 'Serbia',
);

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

  Future<void> pumpMini(
    WidgetTester tester, {
    required String design,
    bool useStopX = false,
    String? songTitle,
    Size size = _phone,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<RadioProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: _themeFor(design),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: BoldMiniPlayer(
                    station: _station,
                    subtitle: 'Serbia',
                    playing: true,
                    useStopX: useStopX,
                    nowPlayingTitle: songTitle,
                    onOpen: () {},
                    onPlay: () {},
                    onStop: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('the stop button follows the X setting in the mini player', () {
    for (final design in _designs) {
      testWidgets('$design: a square stop when the setting is off',
          (tester) async {
        await pumpMini(tester, design: design);
        expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsNothing);
      });

      testWidgets('$design: an X when the setting is on', (tester) async {
        await pumpMini(tester, design: design, useStopX: true);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        expect(find.byIcon(Icons.stop_rounded), findsNothing);
      });
    }
  });

  group('the mini player shows the song instead of LIVE', () {
    for (final design in _designs) {
      testWidgets('$design: the song title replaces LIVE', (tester) async {
        await pumpMini(
          tester,
          design: design,
          songTitle: 'Alan Walker - Darkside',
        );
        expect(find.text('Alan Walker - Darkside'), findsWidgets);
        expect(find.text('LIVE'), findsNothing);
      });

      testWidgets('$design: the fallback stays when there is no title',
          (tester) async {
        await pumpMini(tester, design: design);
        // While a station plays, the cyber, modern and abstract designs show
        // LIVE. The classic one shows the region instead. Either way the song
        // line is empty when the station publishes no title.
        if (design == 'classic') {
          expect(find.text('Serbia'), findsWidgets);
        } else {
          expect(find.text('LIVE'), findsWidgets);
        }
      });
    }
  });

  testWidgets('a long song title scrolls on its own', (tester) async {
    const longTitle =
        'Alan Walker - Darkside (Extended Mix) feat. Noor - 2024 Remaster';
    await pumpMini(
      tester,
      design: 'classic',
      songTitle: longTitle,
    );

    // The scrolling line is a marquee, not a clipped text.
    expect(find.byType(BoldMarquee), findsOneWidget);
    expect(find.byType(BoldMarquee), findsWidgets);

    // The text itself is wider than the space it gets, so it has to move.
    final marquee = tester.getRect(find.byType(BoldMarquee));
    final copies = find.descendant(
      of: find.byType(BoldMarquee),
      matching: find.text(longTitle),
    );
    // Two copies of the text, one period apart: that is what makes the loop
    // seamless.
    expect(copies, findsNWidgets(2));
    final textWidth = tester.getSize(copies.first).width;
    expect(textWidth, greaterThan(marquee.width),
        reason: 'the title must be wider than the line to scroll');

    // The line moves: two samples at different times must differ.
    final first = tester.getTopLeft(copies.first);
    await tester.pump(const Duration(milliseconds: 1200));
    final second = tester.getTopLeft(copies.first);
    expect(second.dx, isNot(equals(first.dx)),
        reason: 'the title must scroll on its own');
    expect(second.dx, lessThan(first.dx),
        reason: 'the title must scroll to the left');
  });

  testWidgets('a short song title does not scroll', (tester) async {
    await pumpMini(
      tester,
      design: 'classic',
      songTitle: 'Darkside',
    );
    expect(find.byType(BoldMarquee), findsOneWidget);

    // The text fits: the widget falls back to a plain Text.
    expect(
      find.descendant(
        of: find.byType(BoldMarquee),
        matching: find.text('Darkside'),
      ),
      findsOneWidget,
    );
  });
}
