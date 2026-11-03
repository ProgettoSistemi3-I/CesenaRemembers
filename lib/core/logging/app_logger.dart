import 'dart:async';
import 'dart:developer' as developer;

import 'crashlytics_reporter.dart';

class AppLogger {
  const AppLogger._();

  static void info(String message, {String name = 'CesenaRemembers'}) {
    developer.log(message, name: name);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'CesenaRemembers',
  }) {
    developer.log(message, name: name, error: error, stackTrace: stackTrace);

    if (error != null) {
      unawaited(
        CrashlyticsReporter.record(
          error,
          stackTrace ?? StackTrace.current,
          reason: 'Handled application error in $name',
        ),
      );
    }
  }
}
