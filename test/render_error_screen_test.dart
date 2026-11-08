import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/presentation/widgets/render_error_screen.dart';

void main() {
  testWidgets('render error screen shows a generic message and retry action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RenderErrorScreen(),
      ),
    );

    expect(find.textContaining('Si è verificato un problema'), findsOneWidget);
    expect(find.text('Riprova / Try again'), findsOneWidget);
    expect(find.textContaining('Stack trace'), findsNothing);
    expect(find.textContaining('FlutterErrorDetails'), findsNothing);
  });

  testWidgets('retry action invokes the recovery callback', (tester) async {
    var retryTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RenderErrorScreen(
          onRetry: () => retryTriggered = true,
        ),
      ),
    );

    await tester.tap(find.text('Riprova / Try again'));
    await tester.pump();

    expect(retryTriggered, isTrue);
  });
}
