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
    // Keep the existing map mounted during permission re-checks. The flag is
    // initialized to true and is cleared by the first completed verification.

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

  Future<LatLng?> _getRecentLastKnownLocation() async {
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) return null;

      final age = DateTime.now().difference(lastKnown.timestamp);
      // A cached fix is useful for avoiding an unnecessary GPS cold-start
      // delay, but must remain recent so it cannot start a tour far from the
      // user's actual position.
      if (age < Duration.zero || age > const Duration(seconds: 30)) {
        return null;
      }
      return LatLng(lastKnown.latitude, lastKnown.longitude);
    } catch (_) {
      // Some providers do not expose a cached position.
      return null;
    }
  }

  Future<LatLng?> _getCurrentDeviceLocation() async {
    // Prefer a recent cached fix: getCurrentPosition may wait several seconds
    // for a fresh GPS fix even when Android permissions and GPS are enabled.
    final recentLastKnown = await _getRecentLastKnownLocation();
    if (recentLastKnown != null) return recentLastKnown;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return _getRecentLastKnownLocation();
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
        _showOutsideCesenaNotification();
        return;
      }

      _removeOutsideCesenaNotification();
      _updateMapState(() {
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
