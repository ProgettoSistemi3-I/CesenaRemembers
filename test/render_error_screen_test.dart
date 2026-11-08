import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/presentation/pages/splash_screen.dart';
import 'package:cesena_remembers/presentation/services/push_notification_service.dart';
import 'package:cesena_remembers/presentation/widgets/render_error_screen.dart';

void main() {
  testWidgets('render error screen shows a generic message and retry action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: PushNotificationService.navigatorKey,
        home: const RenderErrorScreen(),
      ),
    );

    expect(find.textContaining('Si è verificato un problema'), findsOneWidget);
    expect(find.text('Riprova / Try again'), findsOneWidget);
    expect(find.textContaining('Stack trace'), findsNothing);
    expect(find.textContaining('FlutterErrorDetails'), findsNothing);
  });

  testWidgets('retry returns the navigation stack to the splash screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: PushNotificationService.navigatorKey,
        home: const RenderErrorScreen(),
      ),
    );

    await tester.tap(find.text('Riprova / Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
