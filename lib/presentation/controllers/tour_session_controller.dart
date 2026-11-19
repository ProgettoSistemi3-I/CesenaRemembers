import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/shared_position_stream.dart';
import '../services/tour_foreground_service.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/tour_stop.dart';
import '../../domain/services/tour_route_planner.dart';
import '../services/tour_session_store.dart';

const double defaultArrivedThresholdMeters = 50.0;
const LatLng defaultCesenaCenter = LatLng(44.143043, 12.253486);

enum TourStatus { idle, running, arrived }

class TourSessionController {
  TourSessionController({
    required List<TourStop> availableStops,
    this._routePlanner = const TourRoutePlanner(),
    this._arrivedThresholdMeters = defaultArrivedThresholdMeters,
    this._originResolver,
    this._positionStreamFactory,
    Future<LocationPermission> Function()? locationPermissionChecker,
    Future<void> Function()? stopForegroundService,
    TourSessionStore? sessionStore,
  }) : _availableStops = List.unmodifiable(availableStops),
       _sessionStore = sessionStore ?? TourSessionStore(),
       _locationPermissionChecker =
           locationPermissionChecker ?? Geolocator.checkPermission,
       _stopForegroundService =
           stopForegroundService ?? TourForegroundService.stop;

  final List<TourStop> _availableStops;
  final TourRoutePlanner _routePlanner;
  final double _arrivedThresholdMeters;
  final Future<LatLng> Function()? _originResolver;
  final Stream<Position> Function()? _positionStreamFactory;
  final TourSessionStore _sessionStore;
  final Future<LocationPermission> Function() _locationPermissionChecker;
  final Future<void> Function() _stopForegroundService;

  final StreamController<void> _updates = StreamController<void>.broadcast();

  Stream<void> get updates => _updates.stream;

  TourStatus _status = TourStatus.idle;
  List<TourStop> _orderedStops = [];
  int _currentStopIndex = 0;
  LatLng? _userPosition;
  bool _hasRealUserPosition = false;
  int? _userPositionAtEpochMs;
  int _elapsedSeconds = 0;
  int _totalElapsedSeconds = 0;
  int _tourStartedAtEpochMs = 0;
  int _currentLegStartedAtEpochMs = 0;
  int _lastTimerTickEpochMs = 0;
  int _lastPersistenceAtEpochMs = 0;
  Future<void> _persistenceQueue = Future<void>.value();

  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  TourStatus get status => _status;
  bool get isActive => _status != TourStatus.idle;
  bool get isArrived => _status == TourStatus.arrived;
  int get elapsedSeconds => _elapsedSeconds;
  int get totalElapsedSeconds => _totalElapsedSeconds;
  int get tourStartedAtEpochMs => _tourStartedAtEpochMs;
  int get currentLegStartedAtEpochMs => _currentLegStartedAtEpochMs;
  List<TourStop> get orderedStops => List.unmodifiable(_orderedStops);
  int get currentStopIndex => _currentStopIndex;
  TourStop? get currentStop =>
      _orderedStops.isEmpty ? null : _orderedStops[_currentStopIndex];
  LatLng? get userPosition => _userPosition;

  List<TourStop> get upcomingStops {
    if (_orderedStops.isEmpty || _currentStopIndex >= _orderedStops.length) {
      return const [];
    }
    return List.unmodifiable(_orderedStops.sublist(_currentStopIndex));
  }

  List<double?> get upcomingStopsDistanceFromPrevious {
    if (_orderedStops.isEmpty || _currentStopIndex >= _orderedStops.length) {
      return const [];
    }

    final distance = const Distance();
    return List<double?>.generate(upcomingStops.length, (relativeIndex) {
      final absoluteIndex = _currentStopIndex + relativeIndex;
      if (absoluteIndex == 0) return null;
      return distance.as(
        LengthUnit.Meter,
        _toLatLng(_orderedStops[absoluteIndex - 1].position),
        _toLatLng(_orderedStops[absoluteIndex].position),
      );
    }, growable: false);
  }

  double get distanceToCurrentStop {
    final stop = currentStop;
    if (stop == null || _userPosition == null) return -1;
    return const Distance().as(
      LengthUnit.Meter,
      _userPosition!,
      _toLatLng(stop.position),
    );
  }

  bool get hasStops => _availableStops.isNotEmpty;

  /// Restores a saved tour after the Flutter activity or process is recreated.
  /// The time elapsed while the process was unavailable is added from the
  /// locally persisted timestamp.
  Future<bool> restoreSession() async {
    if (isActive || _availableStops.isEmpty) return false;

    await _persistenceQueue;
    final snapshot = await _sessionStore.loadSession();
    if (snapshot == null) return false;

    final permission = await _locationPermissionChecker();
    final hasLocationPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!hasLocationPermission) {
      // An interrupted tour cannot safely resume without location access.
      // Clear the persisted session and stop any sticky Android service.
      await _sessionStore.clearSession();
      await _sessionStore.clearResults();
      try {
        await _stopForegroundService();
      } catch (error) {
        debugPrint('[TourSession] Unable to stop foreground service: $error');
      }
      return false;
    }

    final stopsById = {for (final stop in _availableStops) stop.id: stop};
    final restoredStops = <TourStop>[];
    for (final stopId in snapshot.orderedStopIds) {
      final stop = stopsById[stopId];
      if (stop == null) {
        await _sessionStore.clearSession();
        await _sessionStore.clearResults();
        return false;
      }
      restoredStops.add(stop);
    }

    if (restoredStops.isEmpty ||
        snapshot.currentStopIndex < 0 ||
        snapshot.currentStopIndex >= restoredStops.length ||
        snapshot.startedAtEpochMs <= 0) {
      await _sessionStore.clearSession();
      await _sessionStore.clearResults();
      return false;
    }

    final restoredStatus = snapshot.status == 'arrived'
        ? TourStatus.arrived
        : TourStatus.running;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedWhileClosed = math.max(
      0,
      (now - snapshot.savedAtEpochMs) ~/ 1000,
    ).toInt();

    _orderedStops = List.unmodifiable(restoredStops);
    _currentStopIndex = snapshot.currentStopIndex;
    _status = restoredStatus;
    _tourStartedAtEpochMs = snapshot.startedAtEpochMs;
    _totalElapsedSeconds = snapshot.totalElapsedSeconds + elapsedWhileClosed;
    _elapsedSeconds = snapshot.elapsedSeconds +
        (restoredStatus == TourStatus.running ? elapsedWhileClosed : 0);
    _currentLegStartedAtEpochMs = now - (_elapsedSeconds * 1000);
    _lastTimerTickEpochMs = now;
    _lastPersistenceAtEpochMs = now;

    if (snapshot.userLatitude != null && snapshot.userLongitude != null) {
      _userPosition = LatLng(
        snapshot.userLatitude!,
        snapshot.userLongitude!,
      );
      final positionAge = snapshot.userPositionAtEpochMs == null
          ? null
          : now - snapshot.userPositionAtEpochMs!;
      _userPositionAtEpochMs = snapshot.userPositionAtEpochMs;
      _hasRealUserPosition =
          positionAge != null && positionAge >= 0 && positionAge <= 30000;
    } else {
      _userPositionAtEpochMs = null;
      _hasRealUserPosition = false;
    }

    _startPositionTracking();
    _startTimer();
    if (_status == TourStatus.running) _checkCurrentStopArrival();
    _emit();
    return true;
  }

  Future<bool> startTour({LatLng? origin}) async {
    if (_availableStops.isEmpty) {
      _status = TourStatus.idle;
      _orderedStops = [];
      _currentStopIndex = 0;
      _elapsedSeconds = 0;
      _totalElapsedSeconds = 0;
      _emit();
      return false;
    }

    final startOrigin = origin ?? await _resolveOrigin();
    if (origin != null) {
      _userPosition = origin;
      _hasRealUserPosition = true;
      _userPositionAtEpochMs = DateTime.now().millisecondsSinceEpoch;
    }

    _orderedStops = _routePlanner.sortNearestNeighbor(
      origin: GeoPoint(latitude: startOrigin.latitude, longitude: startOrigin.longitude),
      stops: _availableStops,
    );
    _currentStopIndex = 0;
    _elapsedSeconds = 0;
    _totalElapsedSeconds = 0;
    _tourStartedAtEpochMs = DateTime.now().millisecondsSinceEpoch;
    _currentLegStartedAtEpochMs = _tourStartedAtEpochMs;
    _lastTimerTickEpochMs = _tourStartedAtEpochMs;
    _lastPersistenceAtEpochMs = _tourStartedAtEpochMs;
    _status = TourStatus.running;

    await _sessionStore.clearResults();
    _startPositionTracking();
    _startTimer();
    _checkCurrentStopArrival();
    await _enqueueSessionPersistence();
    _emit();
    return true;
  }

  bool advanceToNextStop() {
    if (_currentStopIndex < _orderedStops.length - 1) {
      _currentStopIndex++;
      _status = TourStatus.running;
      _elapsedSeconds = 0;
      final legStartedAt = DateTime.now().millisecondsSinceEpoch;
      _currentLegStartedAtEpochMs = legStartedAt;
      _lastTimerTickEpochMs = legStartedAt;
      _emit();
      _checkCurrentStopArrival();
      _startTimer();
      _queueSessionPersistence();
      return true;
    }

    // Keep the accumulated quiz results until the completion animation closes.
    stopTour(clearResults: false);
    return false;
  }

  void stopTour({bool clearResults = true}) {
    _stopTracking();
    _status = TourStatus.idle;
    _orderedStops = [];
    _currentStopIndex = 0;
    _elapsedSeconds = 0;
    _totalElapsedSeconds = 0;
    _tourStartedAtEpochMs = 0;
    _currentLegStartedAtEpochMs = 0;
    _userPositionAtEpochMs = null;
    _lastTimerTickEpochMs = 0;
    _lastPersistenceAtEpochMs = 0;
    _queueClearPersistedSession(clearResults: clearResults);
    _emit();
  }

  void reorderUpcomingStops({
    required int oldRelativeIndex,
    required int newRelativeIndex,
  }) {
    if (!isActive) return;

    final upcomingLength = _orderedStops.length - _currentStopIndex;
    if (upcomingLength < 2) return;
    if (oldRelativeIndex < 0 || oldRelativeIndex >= upcomingLength) return;
    if (newRelativeIndex < 0 || newRelativeIndex >= upcomingLength) return;
    final absoluteOldIndex = _currentStopIndex + oldRelativeIndex;
    final absoluteNewIndex = _currentStopIndex + newRelativeIndex;

    final movedStop = _orderedStops.removeAt(absoluteOldIndex);
    _orderedStops.insert(absoluteNewIndex, movedStop);

    if (oldRelativeIndex == 0 || newRelativeIndex == 0) {
      _elapsedSeconds = 0;
      final legStartedAt = DateTime.now().millisecondsSinceEpoch;
      _currentLegStartedAtEpochMs = legStartedAt;
      _lastTimerTickEpochMs = legStartedAt;
      if (_status == TourStatus.arrived) _status = TourStatus.running;
      _checkCurrentStopArrival();
      _startTimer();
    }

    _emit();
    _queueSessionPersistence();
  }

  Future<void> refreshPermissionsState() async {
    _emit();
  }

  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _updates.close();
  }

  Future<LatLng> _resolveOrigin() async {
    final resolver = _originResolver;
    if (resolver != null) {
      final origin = await resolver();
      _userPosition = origin;
      _hasRealUserPosition = true;
      _userPositionAtEpochMs = DateTime.now().millisecondsSinceEpoch;
      return origin;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 4));
      _userPosition = LatLng(pos.latitude, pos.longitude);
      _hasRealUserPosition = true;
      _userPositionAtEpochMs = DateTime.now().millisecondsSinceEpoch;
      return _userPosition!;
    } catch (_) {
      _hasRealUserPosition = false;
      _userPositionAtEpochMs = null;
      _userPosition = defaultCesenaCenter;
      return defaultCesenaCenter;
    }
  }

  void _startPositionTracking() {
    _positionSubscription?.cancel();
    final positions =
        _positionStreamFactory?.call() ?? SharedPositionStream.positions;
    _positionSubscription = positions.listen(
      (position) {
        _userPosition = LatLng(position.latitude, position.longitude);
        _hasRealUserPosition = true;
        _userPositionAtEpochMs = DateTime.now().millisecondsSinceEpoch;
        _checkCurrentStopArrival();
        if (_status != TourStatus.arrived) _emit();

        final now = DateTime.now().millisecondsSinceEpoch;
        if (isActive && now - _lastPersistenceAtEpochMs >= 15000) {
          _queueSessionPersistence();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        // Un errore del GPS non deve terminare silenziosamente il tour.
        _emit();
      },
    );
  }

  void _checkCurrentStopArrival() {
    if (_status != TourStatus.running || !_hasRealUserPosition) return;
    final distance = distanceToCurrentStop;
    if (distance >= 0 && distance <= _arrivedThresholdMeters) {
      _triggerArrival();
    }
  }

  void _triggerArrival() {
    if (_status == TourStatus.arrived) return;
    _status = TourStatus.arrived;
    _emit();
    _queueSessionPersistence();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isActive) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedTicks = math.max(
        0,
        (now - _lastTimerTickEpochMs) ~/ 1000,
      ).toInt();
      if (elapsedTicks == 0) return;

      _totalElapsedSeconds += elapsedTicks;
      if (_status == TourStatus.running) {
        _elapsedSeconds += elapsedTicks;
      }
      _lastTimerTickEpochMs += elapsedTicks * 1000;

      if (now - _lastPersistenceAtEpochMs >= 10000) {
        _queueSessionPersistence();
      }
      _emit();
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _timer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _queueSessionPersistence() {
    if (!isActive || _orderedStops.isEmpty || _tourStartedAtEpochMs <= 0) {
      return;
    }
    unawaited(_enqueueSessionPersistence());
  }

  Future<void> _enqueueSessionPersistence() {
    if (!isActive || _orderedStops.isEmpty || _tourStartedAtEpochMs <= 0) {
      return Future<void>.value();
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final snapshot = TourSessionSnapshot(
      orderedStopIds: _orderedStops.map((stop) => stop.id).toList(growable: false),
      currentStopIndex: _currentStopIndex,
      status: _status.name,
      elapsedSeconds: _elapsedSeconds,
      totalElapsedSeconds: _totalElapsedSeconds,
      savedAtEpochMs: now,
      startedAtEpochMs: _tourStartedAtEpochMs,
      userLatitude: _userPosition?.latitude,
      userLongitude: _userPosition?.longitude,
      userPositionAtEpochMs: _userPositionAtEpochMs,
    );
    _lastPersistenceAtEpochMs = now;

    _persistenceQueue = _persistenceQueue.then((_) async {
      await _sessionStore.saveSession(snapshot);
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('[TourSession] Persist failed: $error');
    });
    return _persistenceQueue;
  }

  void _queueClearPersistedSession({required bool clearResults}) {
    _persistenceQueue = _persistenceQueue.then((_) async {
      await _sessionStore.clearSession();
      if (clearResults) await _sessionStore.clearResults();
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('[TourSession] Clear persisted session failed: $error');
    });
  }

  void _emit() {
    if (!_updates.isClosed) {
      _updates.add(null);
    }
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
