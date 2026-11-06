import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Una sorgente broadcast condivisa. Se il permesso GPS viene revocato e poi
/// concesso di nuovo nella stessa sessione, il flusso viene riaperto senza
/// richiedere ai consumer di ricreare la sottoscrizione.
class SharedPositionStream {
  SharedPositionStream._();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  static const Duration _retryDelay = Duration(seconds: 5);

  static final StreamController<Position> _controller =
      StreamController<Position>.broadcast(
        onListen: _start,
        onCancel: _stop,
      );

  static StreamSubscription<Position>? _subscription;
  static Timer? _retryTimer;
  static bool _isConnecting = false;

  static Stream<Position> get positions => _controller.stream;

  static Future<void> _start() async {
    if (_isConnecting || _subscription != null || !_controller.hasListener) {
      return;
    }

    _isConnecting = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!serviceEnabled || !hasPermission) {
        _scheduleRetry();
        return;
      }

      // L'ultimo listener potrebbe essersi disiscritto durante i controlli.
      if (!_controller.hasListener) return;

      _subscription = Geolocator.getPositionStream(
        locationSettings: _settings,
      ).listen(
        _controller.add,
        onError: (Object error, StackTrace stackTrace) {
          final failedSubscription = _subscription;
          _subscription = null;
          if (failedSubscription != null) {
            unawaited(failedSubscription.cancel());
          }
          if (_controller.hasListener) {
            _controller.addError(error, stackTrace);
          }
          _scheduleRetry();
        },
        onDone: () {
          _subscription = null;
          _scheduleRetry();
        },
      );

      if (!_controller.hasListener) {
        _stop();
      }
    } catch (error, stackTrace) {
      if (_controller.hasListener) {
        _controller.addError(error, stackTrace);
      }
      _scheduleRetry();
    } finally {
      _isConnecting = false;
    }
  }

  static void _scheduleRetry() {
    if (!_controller.hasListener || _retryTimer != null) return;

    _retryTimer = Timer(_retryDelay, () {
      _retryTimer = null;
      unawaited(_start());
    });
  }

  static void _stop() {
    _retryTimer?.cancel();
    _retryTimer = null;

    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }
}
