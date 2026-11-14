import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// A broadcast position source that retries after permission/service failures
/// and after the platform position stream ends or emits an error.
class RecoveringPositionStream {
  RecoveringPositionStream({
    required this._isLocationServiceEnabled,
    required this._checkPermission,
    required this._openPositionStream,
    this.retryDelay = const Duration(seconds: 5),
  }) {
    _controller = StreamController<Position>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
  }

  final Future<bool> Function() _isLocationServiceEnabled;
  final Future<LocationPermission> Function() _checkPermission;
  final Stream<Position> Function() _openPositionStream;
  final Duration retryDelay;

  late final StreamController<Position> _controller;
  StreamSubscription<Position>? _subscription;
  Timer? _retryTimer;
  bool _isConnecting = false;

  Stream<Position> get positions => _controller.stream;

  Future<void> _start() async {
    if (_isConnecting || _subscription != null || !_controller.hasListener) {
      return;
    }

    _isConnecting = true;
    try {
      final serviceEnabled = await _isLocationServiceEnabled();
      final permission = await _checkPermission();
      final hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!serviceEnabled || !hasPermission) {
        _scheduleRetry();
        return;
      }

      // The last listener may have unsubscribed while the checks were pending.
      if (!_controller.hasListener) return;

      _subscription = _openPositionStream().listen(
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

  void _scheduleRetry() {
    if (!_controller.hasListener || _retryTimer != null) return;

    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      unawaited(_start());
    });
  }

  void _stop() {
    _retryTimer?.cancel();
    _retryTimer = null;

    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  Future<void> dispose() async {
    _stop();
    await _controller.close();
  }
}

/// App-wide shared GPS source. Consumers can keep their subscription alive
/// while [RecoveringPositionStream] reopens Geolocator after permission changes.
class SharedPositionStream {
  SharedPositionStream._();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  static final RecoveringPositionStream _source = RecoveringPositionStream(
    isLocationServiceEnabled: Geolocator.isLocationServiceEnabled,
    checkPermission: Geolocator.checkPermission,
    openPositionStream: () => Geolocator.getPositionStream(
      locationSettings: _settings,
    ),
  );

  static Stream<Position> get positions => _source.positions;
}
