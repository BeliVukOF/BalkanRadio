import 'package:balkan_radio/ui/bold/bold_theme.dart';
import 'package:balkan_radio/ui/bold/bold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('play/pause icon crossfades instead of cutting instantly',
      (tester) async {
    await tester.pumpWidget(const _Harness());
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byType(BoldOrb));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('reduced motion changes the icon immediately', (tester) async {
    await tester.pumpWidget(
      const _Harness(reducedMotion: true),
    );
    await tester.tap(find.byType(BoldOrb));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });
}

class _Harness extends StatefulWidget {
  const _Harness({this.reducedMotion = false});

  final bool reducedMotion;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BoldTheme.darkTheme,
      builder: (context, child) => widget.reducedMotion
          ? MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : child!,
      home: Scaffold(
        body: Center(
          child: BoldOrb(
            icon: _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: () => setState(() => _playing = !_playing),
          ),
        ),
      ),
    );
  }
}
