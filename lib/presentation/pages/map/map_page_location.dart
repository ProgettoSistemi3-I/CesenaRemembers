part of 'map_page.dart';

extension _MapPageLocationLogic on _MapPageState {
  void _onGpsPreferenceChanged() {
    if (!mounted) return;
    final enabled = LocationPreferenceStore.gpsEnabled.value;
    _updateMapState(() {
      _isGpsPreferenceEnabled = enabled;
      if (!enabled) {
        _alignPositionOnUpdate = AlignOnUpdate.never;
      }
    });
  }

  Future<void> _initLocationLogic() async {
    // MainShell ha già richiesto il permesso GPS dopo il primo frame e
    // prima di inizializzare FCM. Qui leggiamo soltanto lo stato definitivo,
    // evitando una seconda richiesta concorrente dal ciclo di vita della mappa.
    await _verifyLocationState(requestPerms: false);
    if (!mounted || kIsWeb) return;
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted) return;
      _updateMapState(() {
        _isGpsEnabled = (status == ServiceStatus.enabled);
      });
      _verifyLocationState(requestPerms: false);
    }, onError: (Object error, StackTrace stackTrace) {
      if (!mounted) return;
      _updateMapState(() => _isGpsEnabled = false);
    });
  }

  Future<void> _verifyLocationState({required bool requestPerms}) async {
    if (mounted) _updateMapState(() => _isCheckingLocation = true);

    try {
      if (kIsWeb) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied && requestPerms) {
          perm = await Geolocator.requestPermission();
        }
        final hasPerm =
            perm == LocationPermission.whileInUse ||
            perm == LocationPermission.always;
        if (mounted) {
          _updateMapState(() {
            _isGpsEnabled = true;
            _hasPermissions = hasPerm;
            _isCheckingLocation = false;
          });
        }
        return;
      }

      final gps = await Geolocator.isLocationServiceEnabled();
      var perm = await Geolocator.checkPermission();

      if (perm == LocationPermission.denied && requestPerms) {
        perm = await Geolocator.requestPermission();
      }

      final hasPerm =
          perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always;

      if (mounted) {
        _updateMapState(() {
          _isGpsEnabled = gps;
          _hasPermissions = hasPerm;
          _isCheckingLocation = false;
        });
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unable to verify location permission state',
        error: error,
        stackTrace: stackTrace,
        name: 'MapPage',
      );
      if (mounted) {
        _updateMapState(() {
          _isGpsEnabled = false;
          _hasPermissions = false;
          _isCheckingLocation = false;
        });
      }
    }
  }

  Future<void> _resolveLocationIssues() async {
    ShellNavigationStore.openSettingsAndFocusGpsToggle();
  }

  Future<LatLng?> _getCurrentDeviceLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
      } catch (_) {
        // A missing or stale position must not be replaced with Cesena's center.
      }
      return null;
    }
  }

  Future<void> _centerOnUserLocation() async {
    if (_isCenteringOnUser) return;

    if (!_isGpsPreferenceEnabled) {
      _resolveLocationIssues();
      return;
    }

    _updateMapState(() => _isCenteringOnUser = true);

    try {
      await _verifyLocationState(requestPerms: true);
      final canUseLocation =
          _isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled;
      if (!canUseLocation) return;

      final position = await _getCurrentDeviceLocation();
      if (!mounted || position == null) return;

      if (!_MapPageState._cesenaBounds.contains(position)) {
        _updateMapState(() => _isOutsideCesena = true);
        return;
      }

      _updateMapState(() {
        _isOutsideCesena = false;
        _alignPositionOnUpdate = AlignOnUpdate.always;
      });
      _mapController.move(
        position,
        math.max(_mapController.camera.zoom, 16.5),
      );
    } finally {
      if (mounted) {
        _updateMapState(() => _isCenteringOnUser = false);
      }
    }
  }
}
