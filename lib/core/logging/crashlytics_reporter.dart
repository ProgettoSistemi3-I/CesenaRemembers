import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics is disabled by default and enabled only after explicit consent.
class CrashlyticsReporter {
  const CrashlyticsReporter._();

  static bool get _isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isReady =>
      _isSupportedPlatform && Firebase.apps.isNotEmpty;

  static bool _collectionEnabled = false;

  static Future<void> initialize() async {
    if (!_isReady) return;

    try {
      _collectionEnabled = false;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } catch (_) {
      // Diagnostics must never prevent the app from starting.
    }
  }

  /// Enables collection only after the caller has persisted explicit consent.
  ///
  /// Queued reports can be discarded before activation or after withdrawal so
  /// that information generated outside the consent period is not uploaded.
  static Future<void> setCollectionEnabled(
    bool enabled, {
    bool discardUnsentReports = false,
  }) async {
    if (!_isReady) {
      _collectionEnabled = false;
      return;
    }

    final crashlytics = FirebaseCrashlytics.instance;
    try {
      if (!enabled) {
        _collectionEnabled = false;
        await crashlytics.setCrashlyticsCollectionEnabled(false);
        if (discardUnsentReports) {
          await crashlytics.deleteUnsentReports();
        }
        return;
      }

      if (discardUnsentReports) {
        await crashlytics.deleteUnsentReports();
      }
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      _collectionEnabled = true;
    } catch (_) {
      _collectionEnabled = false;
      try {
        await crashlytics.setCrashlyticsCollectionEnabled(false);
      } catch (_) {
        // Keep collection disabled if the platform API is unavailable.
      }
    }
  }

  static Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    if (!_isReady || !_collectionEnabled) return;

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
