import 'package:balkan_radio/l10n/app_localizations.dart';
import 'package:balkan_radio/services/update_service.dart';
import 'package:balkan_radio/ui/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// The update prompt must never be a dead end.
///
/// A user without the "install unknown apps" permission clicked "Install now"
/// and NOTHING happened: no download, no error, no way forward. The permission
/// was requested nowhere and the reason was never shown. These tests pin the
/// fix.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const update = AppUpdate(
    versionName: '9.9.9',
    versionCode: 99,
    apkUrl: 'http://x/BalkanRadio-9.9.9.apk',
  );

  /// Installs a platform-channel mock and returns the recorded calls.
  List<MethodCall> mockPlatform({
    bool canInstall = true,
    bool installSucceeds = true,
  }) {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('balkan_radio/update'),
      (call) async {
        calls.add(call);
        switch (call.method) {
          case 'canRequestPackageInstalls':
            return canInstall;
          case 'requestInstallPermission':
            return true;
          case 'enqueueDownload':
            return 1;
          case 'downloadStatus':
            return <String, dynamic>{
              'state': 'ok',
              'path': '/sdcard/Download/BalkanRadio-9.9.9.apk',
              'progress': 100,
            };
          case 'installApk':
            return installSucceeds;
          default:
            return null;
        }
      },
    );
    return calls;
  }

  Future<UpdateService> pumpDialog(
    WidgetTester tester, {
    required AppUpdate update,
  }) async {
    final service = UpdateService();
    await tester.pumpWidget(
      ChangeNotifierProvider<UpdateService>.value(
        value: service,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showUpdateDialog(context, service),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    service.available = update;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return service;
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('balkan_radio/update'),
      null,
    );
  });

  testWidgets('without the install permission the user is told what to do',
      (tester) async {
    final calls = mockPlatform(canInstall: false);
    await pumpDialog(tester, update: update);

    expect(find.text('Install now'), findsOneWidget);
    await tester.tap(find.text('Install now'));
    // The permission check and the request are async.
    await tester.pumpAndSettle();

    // The dialog must say WHY nothing happened and offer the way out.
    expect(
      find.textContaining('Allow installing from this app'),
      findsWidgets,
      reason: 'the missing install permission is never explained',
    );
    // The way out: a button that opens the system settings.
    expect(
      find.byType(OutlinedButton),
      findsOneWidget,
      reason: 'there is no way to grant the permission from the prompt',
    );
    // The system settings were actually opened.
    expect(
      calls.map((c) => c.method),
      contains('requestInstallPermission'),
      reason: 'the install permission was never requested',
    );
  });

  testWidgets('a failed install is reported instead of failing silently',
      (tester) async {
    mockPlatform(installSucceeds: false);
    await pumpDialog(tester, update: update);

    // Get to the "ready to install" state: the download is polled by a timer,
    // so the dialog needs a few frames.
    await tester.tap(find.text('Install now'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Install'), findsOneWidget);

    await tester.tap(find.text('Install'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('Could not open the installer'),
      findsOneWidget,
      reason: 'a failed install must be reported',
    );
  });
}
