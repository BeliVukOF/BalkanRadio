import 'package:balkan_radio/data/station_repository.dart';
import 'package:balkan_radio/l10n/app_localizations.dart';
import 'package:balkan_radio/providers/radio_provider.dart';
import 'package:balkan_radio/ui/bold/bold_home.dart';
import 'package:balkan_radio/ui/bold/bold_now_playing.dart';
import 'package:balkan_radio/ui/bold/bold_theme.dart';
import 'package:balkan_radio/ui/bold/bold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real phone in landscape: 831 x 377 logical pixels (1224x2700 at 520
/// dpi). Everything has to fit in that height.
const Size _landscape = Size(831, 377);
const Size _portrait = Size(411, 914);

/// The phone runs with the system font scale at 1.15.
const double _fontScale = 1.15;

const _designs = ['classic', 'modern', 'cyber', 'abstract'];

ThemeData _themeFor(String design) => switch (design) {
      'modern' => BoldTheme.modernDarkTheme,
      'cyber' => BoldTheme.cyberDarkTheme,
      'abstract' => BoldTheme.abstractDarkTheme,
      _ => BoldTheme.darkTheme,
    };

Rect _screenRect(WidgetTester tester) {
  final view = tester.view;
  return Rect.fromLTWH(
    0,
    0,
    view.physicalSize.width / view.devicePixelRatio,
    view.physicalSize.height / view.devicePixelRatio,
  );
}

/// Case-insensitive text finder: the cyber design renders station names in
/// upper case (GlitchTitle), so an exact match would miss them.
Finder _textCi(String value) => find.byWidgetPredicate(
      (w) => w is Text && w.data?.toLowerCase() == value.toLowerCase(),
    );

/// A widget is really on screen when its rect stays inside the viewport and
/// it can be hit at its centre (not covered by another widget).
///
/// Some texts exist several times (the cyber design paints three offset
/// layers), so it is enough that ONE of the matches is visible.
void _expectVisible(WidgetTester tester, Finder finder, String what) {
  expect(finder, findsWidgets, reason: '$what is missing');
  final screen = _screenRect(tester);
  final hitTestable = finder.hitTestable().evaluate().toSet();
  var inside = 0;
  var hittable = 0;
  for (final element in finder.evaluate()) {
    final rect = tester.getRect(find.byElementPredicate((e) => e == element));
    if (screen.contains(rect.topLeft) && screen.contains(rect.bottomRight)) {
      inside++;
    }
    if (hitTestable.contains(element)) hittable++;
  }
  expect(inside, greaterThan(0),
      reason: '$what is outside the screen: $screen');
  expect(hittable, greaterThan(0),
      reason: '$what is not hit-testable (covered or clipped)');
}

void main() {
  late RadioProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // The audio service asks the cache manager for a temp directory, which
    // does not exist in a widget test. Without this the plugin error leaks
    // into whichever test happens to run next.
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
    required Widget child,
    required String design,
    required Size size,
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(_fontScale)),
            child: child!,
          ),
          home: child,
        ),
      ),
    );
  }

  /// Opens the full player with a station and a song title loaded.
  Future<void> openPlayer(WidgetTester tester, String design) async {
    await pumpApp(
      tester,
      child: const BoldNowPlaying(),
      design: design,
      size: _landscape,
    );
    for (var i = 0; i < 80 && provider.allStations.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final station = provider.allStations.first;
    provider.debugSetCurrentStation(station);
    provider.nowPlaying.debugSetTitle(station.streamUrl, 'Test Song - Title');
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('landscape', () {
    for (final design in _designs) {
      testWidgets('$design: station rows are visible and the list scrolls',
          (tester) async {
        await pumpApp(
          tester,
          child: const BoldHome(),
          design: design,
          size: _landscape,
        );
        for (var i = 0; i < 80 && provider.allStations.isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        // The mini player sits above the list on the real phone.
        provider.debugSetCurrentStation(provider.allStations.first);
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.byType(BoldStationRow),
          findsWidgets,
          reason: 'no station row was built in landscape',
        );
        _expectVisible(tester, find.byType(BoldStationRow), 'station row');

        final before = tester.getRect(find.byType(BoldStationRow).first);
        await tester.drag(
          find.byType(BoldStationRow).first,
          const Offset(0, -160),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final after = tester.getRect(find.byType(BoldStationRow).first);
        expect(
          after.top,
          isNot(equals(before.top)),
          reason: 'the list did not scroll',
        );
      });

      testWidgets('$design: player metadata and controls fit', (tester) async {
        await openPlayer(tester, design);
        final station = provider.currentStation!;

        _expectVisible(tester, _textCi(station.name), 'station name');
        _expectVisible(tester, find.text('Test Song - Title'), 'song title');
        _expectVisible(
          tester,
          find.byIcon(Icons.bedtime_outlined),
          'sleep button',
        );
        _expectVisible(
          tester,
          find.byIcon(Icons.skip_previous_rounded),
          'previous button',
        );
        _expectVisible(
          tester,
          find.byIcon(Icons.play_arrow_rounded),
          'play button',
        );
        _expectVisible(
          tester,
          find.byIcon(Icons.skip_next_rounded),
          'next button',
        );
        _expectVisible(
          tester,
          find.byIcon(Icons.favorite_border_rounded),
          'favorite button',
        );
      });
    }
  });

  testWidgets('portrait: player metadata and controls still fit', (tester) async {
    // The bundled list is synchronous, so this test never waits for the
    // provider's async station load.
    final station = StationRepository.allStations.first;
    for (final design in _designs) {
      await pumpApp(
        tester,
        child: const BoldNowPlaying(),
        design: design,
        size: _portrait,
      );
      provider.debugSetCurrentStation(station);
      await tester.pump(const Duration(milliseconds: 100));

      _expectVisible(tester, _textCi(station.name), '$design station name');
      _expectVisible(
        tester,
        find.byIcon(Icons.play_arrow_rounded),
        '$design play button',
      );
    }
  });
}
