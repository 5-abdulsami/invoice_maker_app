import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoicemaker/app_bootstrap.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:invoicemaker/presentation/shell/app_shell.dart';
import 'package:invoicemaker/presentation/splash/splash_screen.dart';

void main() {
  testWidgets('shows the splash, then hands over to the app', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      AppBootstrap(
        initialize: () {
          opened++;
          return AppRepositories.inMemory();
        },
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.pumpAndSettle();

    expect(opened, 1, reason: 'storage opens exactly once');
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('waits for storage even after the intro ends', (tester) async {
    final repositories = await AppRepositories.inMemory();
    var release = false;

    await tester.pumpWidget(
      AppBootstrap(
        initialize: () async {
          while (!release) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          return repositories;
        },
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    release = true;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
  });

  for (final size in const [
    Size(320, 480),
    Size(360, 640),
    Size(412, 915),
    Size(640, 360),
    Size(1024, 768),
  ]) {
    testWidgets('splash fits a ${size.width}x${size.height} screen at large '
        'text', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        MaterialApp(home: SplashScreen(onIntroFinished: () {})),
      );
      await tester.pumpAndSettle();

      // A layout overflow is reported as an exception.
      expect(tester.takeException(), isNull);
      expect(find.text(AppStrings.tagline), findsOneWidget);
    });
  }
}
