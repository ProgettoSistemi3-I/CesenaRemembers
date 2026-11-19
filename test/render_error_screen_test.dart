import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/presentation/widgets/render_error_screen.dart';

const _supportedLocales = <Locale>[Locale('it'), Locale('en')];

void main() {
  testWidgets('render error screen falls back to Italian without app localizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('it'),
        supportedLocales: _supportedLocales,
        home: RenderErrorScreen(),
      ),
    );

    expect(
      find.text(
        'Si è verificato un problema durante la visualizzazione. '
        'Torna alla schermata iniziale e riprova.',
      ),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('Stack trace'), findsNothing);
    expect(find.textContaining('FlutterErrorDetails'), findsNothing);
  });

  testWidgets('render error screen falls back to English without app localizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: _supportedLocales,
        home: RenderErrorScreen(),
      ),
    );

    expect(
      find.text(
        'An error occurred while displaying this screen. '
        'Return to the home screen and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('retry action invokes the recovery callback', (tester) async {
    var retryTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        supportedLocales: _supportedLocales,
        home: RenderErrorScreen(
          onRetry: () => retryTriggered = true,
        ),
      ),
    );

    await tester.tap(find.text('Riprova'));
    await tester.pump();

    expect(retryTriggered, isTrue);
  });
}
