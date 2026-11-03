import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized, privacy-conscious Crashlytics reporting.
///
/// Raw exception messages are deliberately not uploaded: backend/plugin
/// messages can contain identifiers, URLs or user-provided data. The original
/// stack trace and exception type are retained for diagnosis.
class CrashlyticsReporter {
  const CrashlyticsReporter._();

  static bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  static bool get _isReady =>
      _isSupportedPlatform && Firebase.apps.isNotEmpty;

  /// Enables collection in release builds and keeps local debug sessions out
  /// of the production Crashlytics dashboard.
  static Future<void> initialize() async {
    if (!_isReady) return;

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
    } catch (_) {
      // Diagnostics must never prevent the app from starting.
    }
  }

  static Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    if (!_isReady) return;

    try {
      await FirebaseCrashlytics.instance.recordError(
        _RedactedCrashlyticsError(error.runtimeType.toString()),
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {
      // Never allow a failure in the reporting pipeline to cause another
      // application failure.
    }
  }
}

class _RedactedCrashlyticsError implements Exception {
  const _RedactedCrashlyticsError(this.originalType);

  final String originalType;

  @override
  String toString() => 'Application exception ($originalType); message redacted';
}
