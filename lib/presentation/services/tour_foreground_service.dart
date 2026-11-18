import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TourForegroundService {
  TourForegroundService._();

  static const MethodChannel _channel = MethodChannel(
    'it.cesenaremembers.app/tour_tracking',
  );

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> startOrUpdate({
    required String notificationTitle,
    required String notificationChannelName,
    required String nextStopLabel,
    required String elapsedLabel,
    required String distanceLabel,
    required String openMapLabel,
    required String stopName,
    required double latitude,
    required double longitude,
    required int startedAtEpochMs,
  }) async {
    if (!_isAndroid) return true;

    await _channel.invokeMethod<void>('startOrUpdate', {
      'notificationTitle': notificationTitle,
      'notificationChannelName': notificationChannelName,
      'nextStopLabel': nextStopLabel,
      'elapsedLabel': elapsedLabel,
      'distanceLabel': distanceLabel,
      'openMapLabel': openMapLabel,
      'stopName': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'startedAtEpochMs': startedAtEpochMs,
    });

    // startForegroundService() only confirms that Android accepted the
    // request. Wait for onStartCommand() to actually enter foreground and
    // report whether the app/channel can display the notification.
    for (var attempt = 0; attempt < 8; attempt++) {
      await Future.delayed(const Duration(milliseconds: 250));
      final status = await _channel.invokeMapMethod<String, dynamic>('getStatus');
      if (status?['isForeground'] == true) {
        return status?['notificationsVisible'] == true;
      }

      final error = status?['lastError'] as String?;
      if (error != null && error.isNotEmpty) {
        throw PlatformException(
          code: 'TOUR_FOREGROUND_START_FAILED',
          message: error,
        );
      }
    }

    throw PlatformException(
      code: 'TOUR_FOREGROUND_START_TIMEOUT',
      message: 'Android did not confirm that the tour service entered foreground',
    );
  }

  static Future<void> stop() async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('stop');
  }
}
