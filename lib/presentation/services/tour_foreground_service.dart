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
    if (!_isAndroid) return;

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
  }

  static Future<void> stop() async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('stop');
  }
}
