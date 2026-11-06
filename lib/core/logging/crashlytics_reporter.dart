import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics is kept disabled while the ePrivacy assessment of installation
/// identifiers and any required consent flow are pending.
class CrashlyticsReporter {
  const CrashlyticsReporter._();

  static bool get _isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isReady =>
      _isSupportedPlatform && Firebase.apps.isNotEmpty;

  static const bool _collectionAllowed = false;

  static Future<void> initialize() async {
    if (!_isReady) return;

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _collectionAllowed,
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
    if (!_isReady || !_collectionAllowed) return;

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
