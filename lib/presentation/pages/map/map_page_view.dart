part of 'map_page.dart';

extension _MapPageView on _MapPageState {
  Widget _buildPage() {
    final data = _buildData;
    final currentMapUrl = switch (_selectedMapStyle) {
      MapStyle.satellite => _MapPageState._urlSatellite,
      MapStyle.standard => data.standardMapUrl,
    };
    const mapTypeButtonHeight = 56.0;
    const mapControlsGap = 12.0;
    const attributionBottomInset = 8.0;
    const tourCardBottom = 82.0 + 12.0 * 2;
    final mapTypeBottom = data.isTourActive ? tourCardBottom : 20.0;
    final attributionVerticalOffset =
        mapTypeBottom +
        mapTypeButtonHeight +
        mapControlsGap -
        attributionBottomInset;

    if (_isLoading || _isCheckingLocation) {
      return Scaffold(
        backgroundColor: data.theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: data.theme.scaffoldBackgroundColor,
        body: _buildErrorState(data.theme),
      );
    }

    return Scaffold(
      backgroundColor: data.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _MapCanvas(
            mapController: _mapController,
            cesenaBounds: _MapPageState._cesenaBounds,
            isMapLocked: _isMapLocked,
            currentRotation: _currentRotation,
            onRotationChanged: _onRotationChanged,
            isMapMenuOpen: _isMapMenuOpen,
            onCloseMapMenu: () => _updateMapState(() => _isMapMenuOpen = false),
            alignPositionOnUpdate: _alignPositionOnUpdate,
            onDisableFollowUser: () => _updateMapState(
              () => _alignPositionOnUpdate = AlignOnUpdate.never,
            ),
            canUseLocation: data.canUseLocation,
            currentMapUrl: currentMapUrl,
            attributionVerticalOffset: attributionVerticalOffset,
            standardMapUrl: data.standardMapUrl,
            selectedMapStyle: _selectedMapStyle,
            cachedTileProvider: _cachedTileProvider,
            markers: _markers,
            routeLinePoints: _routeLinePoints,
            scaffoldBackgroundColor: data.theme.scaffoldBackgroundColor,
            onMapTap: _clearSelectedPoi,
          ),
          _buildOverlay(data),
          _buildPoiPreviewSheet(),
        ],
      ),
    );
  }

  Widget _buildOverlay(_MapBuildData data) {
    const cardHeight = 82.0;
    const cardPadding = 12.0;
    const cardBottom = cardHeight + cardPadding * 2;

    return SafeArea(
      child: Stack(
        children: [
          if (data.isLocationBannerVisible)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: LocationIssueBanner(
                isGpsEnabled: _isGpsEnabled,
                isGpsPreferenceEnabled: _isGpsPreferenceEnabled,
                onResolve: _resolveLocationIssues,
              ),
            ),
          if (_routeUsesMapboxDirections && _routeLinePoints.length >= 2)
            Positioned(
              top: data.isLocationBannerVisible ? 112 : 16,
              right: 16,
              child: Material(
                color: data.theme.colorScheme.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => launchUrl(
                    Uri.parse('https://www.mapbox.com/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.mapLicenseDirectionsAttribution,
                      style: data.theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: data.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            bottom: data.isTourActive ? cardBottom : 20,
            child: MapTypeButton(
              isOpen: _isMapMenuOpen,
              selectedMapStyle: _selectedMapStyle,
              onToggle: () =>
                  _updateMapState(() => _isMapMenuOpen = !_isMapMenuOpen),
              onSelectStandard: () => _updateMapState(() {
                _selectedMapStyle = MapStyle.standard;
                _isMapMenuOpen = false;
              }),
              onSelectSatellite: () => _updateMapState(() {
                _selectedMapStyle = MapStyle.satellite;
                _isMapMenuOpen = false;
              }),
            ),
          ),
          Positioned(
            right: 20,
            bottom: data.isTourActive ? cardBottom + 80 : 90,
            child: CircleFab(
              heroTag: 'lock',
              icon: _isMapLocked ? Icons.lock : Icons.lock_open,
              iconColor: _isMapLocked
                  ? AppPalette.danger
                  : data.theme.colorScheme.onSurfaceVariant,
              onTap: () => _updateMapState(() => _isMapLocked = !_isMapLocked),
            ),
          ),
          Positioned(
            right: 20,
            bottom: data.isTourActive ? cardBottom + 8 : 20,
            child: CircleFab(
              heroTag: 'loc',
              icon: Icons.my_location,
              iconColor: _isCenteringOnUser
                  ? AppPalette.olive
                  : _alignPositionOnUpdate == AlignOnUpdate.always
                  ? AppPalette.olive
                  : data.theme.colorScheme.onSurfaceVariant,
              onTap: _centerOnUserLocation,
            ),
          ),
          if (!data.isTourActive)
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(child: StartTourButton(onTap: _startTour)),
            ),
          if (data.isTourActive)
            Positioned(
              left: 16,
              top: data.isLocationBannerVisible ? 112 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TourQuickActionButton(
                    label: AppLocalizations.of(context)!.tourStopButton,
                    icon: Icons.stop_circle_outlined,
                    color: AppPalette.danger,
                    onTap: _confirmStopTour,
                  ),
                  const SizedBox(height: 10),
                  TourQuickActionButton(
                    label: AppLocalizations.of(context)!.tourOrderButton,
                    icon: Icons.format_list_bulleted_rounded,
                    color: AppPalette.olive,
                    onTap: _openTourPlanSheet,
                  ),
                ],
              ),
            ),
          if (data.isTourActive && data.currentStop != null)
            Positioned(
              bottom: cardPadding,
              left: 16,
              right: 16,
              child: NextStopCard(
                stop: data.currentStop!,
                icon: data.currentStopVisual!.icon,
                iconBackground: data.currentStopVisual!.iconBackground,
                stopIndex: _tourController.currentStopIndex,
                totalStops: _tourController.orderedStops.length,
                distanceMeters: _tourController.distanceToCurrentStop,
                elapsedSeconds: _tourController.elapsedSeconds,
                arrived: _tourController.isArrived,
                onTap: _tourController.isArrived
                    ? _openPoiPopup
                    : () => _centerOnStop(
                        LatLng(
                          data.currentStop!.position.latitude,
                          data.currentStop!.position.longitude,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPoiPreviewSheet() {
    final selectedPoi = _selectedPoi;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: selectedPoi == null,
        child: AnimatedSlide(
          offset: selectedPoi == null ? const Offset(0, 1) : Offset.zero,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: selectedPoi == null ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            child: selectedPoi == null
                ? const SizedBox.shrink()
                : PoiPreviewSheet(poi: selectedPoi, onClose: _clearSelectedPoi),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppPalette.danger, size: 42),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.errorLoadPoi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _updateMapState(() => _isLoading = true);
                _loadPois();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.olive,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.buttonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCanvas extends StatefulWidget {
  const _MapCanvas({
    required this.mapController,
    required this.cesenaBounds,
    required this.isMapLocked,
    required this.currentRotation,
    required this.onRotationChanged,
    required this.isMapMenuOpen,
    required this.onCloseMapMenu,
    required this.alignPositionOnUpdate,
    required this.onDisableFollowUser,
    required this.canUseLocation,
    required this.currentMapUrl,
    required this.attributionVerticalOffset,
    required this.standardMapUrl,
    required this.selectedMapStyle,
    required this.cachedTileProvider,
    required this.markers,
    required this.routeLinePoints,
    required this.scaffoldBackgroundColor,
    required this.onMapTap,
  });

  final MapController mapController;
  final LatLngBounds cesenaBounds;
  final bool isMapLocked;
  final double currentRotation;
  final ValueChanged<double> onRotationChanged;
  final bool isMapMenuOpen;
  final VoidCallback onCloseMapMenu;
  final AlignOnUpdate alignPositionOnUpdate;
  final VoidCallback onDisableFollowUser;
  final bool canUseLocation;
  final String currentMapUrl;
  final double attributionVerticalOffset;
  final String standardMapUrl;
  final MapStyle selectedMapStyle;
  final CachedTileProvider? cachedTileProvider;
  final List<Marker> markers;
  final List<LatLng> routeLinePoints;
  final Color scaffoldBackgroundColor;
  final VoidCallback onMapTap;

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  // Il position stream viene creato UNA SOLA VOLTA e riutilizzato ad ogni rebuild.
  // Se fosse dentro build(), verrebbe ricreato ad ogni _updateMapState() del genitore
  // (es. ogni secondo durante il tour), causando N subscription aperte.
  late final Stream<LocationMarkerPosition?> _positionStream =
      const LocationMarkerDataStreamFactory().fromGeolocatorPositionStream(
        stream: SharedPositionStream.positions,
      );

  static const _defaultCesenaCenter = LatLng(44.1384, 12.2471);

  static const _mapboxLogoUrl =
      'https://cdn.prod.website-files.com/6050a76fa6a633d5d54ae714/657a891ba7274ba4f8b3a168_img-main-logo.png';

  List<SourceAttribution> _mapAttributions() {
    if (widget.selectedMapStyle == MapStyle.satellite) {
      return [
        TextSourceAttribution(
          '© Mapbox',
          onTap: () => launchUrl(
            Uri.parse('https://www.mapbox.com/about/maps/'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        TextSourceAttribution(
          '© OpenStreetMap',
          onTap: () => launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        TextSourceAttribution(
          'Improve this map',
          onTap: () async {
            final camera = widget.mapController.camera;
            final feedbackUrl = Uri.parse(
              'https://apps.mapbox.com/feedback/#/'
              '${camera.center.longitude}/${camera.center.latitude}/${camera.zoom}',
            );
            await launchUrl(feedbackUrl, mode: LaunchMode.externalApplication);
          },
        ),
        TextSourceAttribution(
          '© Maxar',
          onTap: () => launchUrl(
            Uri.parse('https://www.maxar.com/'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ];
    }
    if (widget.currentMapUrl.contains('stadiamaps.com')) {
      return [
        TextSourceAttribution(
          '© Stadia Maps',
          onTap: () =>
              launchUrl(Uri.parse('https://stadiamaps.com/attribution/')),
        ),
        TextSourceAttribution(
          '© OpenMapTiles',
          onTap: () => launchUrl(Uri.parse('https://openmaptiles.org/')),
        ),
        TextSourceAttribution(
          '© OpenStreetMap contributors',
          onTap: () =>
              launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
        ),
      ];
    }
    return [
      TextSourceAttribution(
        '© OpenStreetMap contributors',
        onTap: () =>
            launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
      ),
      TextSourceAttribution(
        '© CARTO',
        onTap: () => launchUrl(Uri.parse('https://carto.com/attributions/')),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: _defaultCesenaCenter,
            initialZoom: 14.0,
            minZoom: 10.0,
            maxZoom: 18.5,
            cameraConstraint: CameraConstraint.contain(
              bounds: widget.cesenaBounds,
            ),
            backgroundColor: widget.scaffoldBackgroundColor,
            interactionOptions: InteractionOptions(
              flags: widget.isMapLocked
                  ? InteractiveFlag.none
                  : InteractiveFlag.all,
            ),
            onTap: (_, _) => widget.onMapTap(),
            onMapEvent: (event) {
              if (event is MapEventMove || event is MapEventRotate) {
                final rotation = widget.mapController.camera.rotation;
                if ((rotation - widget.currentRotation).abs() > 0.1) {
                  widget.onRotationChanged(rotation);
                }
              }
              if (event is MapEventMoveStart && widget.isMapMenuOpen) {
                widget.onCloseMapMenu();
              }
            },
            onPositionChanged: (_, hasGesture) {
              if (hasGesture &&
                  widget.alignPositionOnUpdate != AlignOnUpdate.never) {
                widget.onDisableFollowUser();
              }
            },
          ),
          children: [
            TileLayer(
              key: ValueKey(widget.currentMapUrl),
              urlTemplate: widget.currentMapUrl,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'it.cesenaremembers.app',
              maxZoom: 19,
              tileBounds: widget.cesenaBounds,
              tileProvider: widget.cachedTileProvider,
            ),
            if (widget.routeLinePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routeLinePoints,
                    color: AppPalette.olive,
                    strokeWidth: 5,
                    borderColor: Colors.white.withValues(alpha: 0.85),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            if (widget.canUseLocation)
              CurrentLocationLayer(
                alignPositionOnUpdate: widget.alignPositionOnUpdate,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    color: Colors.blue,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  accuracyCircleColor: Colors.blue.withValues(alpha: 0.1),
                  headingSectorColor: Colors.blue.withValues(alpha: 0.2),
                ),
                positionStream: _positionStream,
              ),
            MarkerLayer(markers: widget.markers),
            if (!widget.isMapMenuOpen)
              Transform.translate(
                offset: Offset(
                  0,
                  -(widget.attributionVerticalOffset +
                      MediaQuery.of(context).padding.bottom),
                ),
                child: RichAttributionWidget(
                  alignment: widget.selectedMapStyle == MapStyle.satellite
                      ? AttributionAlignment.bottomRight
                      : AttributionAlignment.bottomLeft,
                  showFlutterMapAttribution: false,
                  attributions: _mapAttributions(),
                ),
              ),
          ],
        ),
        if (widget.selectedMapStyle == MapStyle.satellite &&
            !widget.isMapMenuOpen)
          Positioned(
            left: 8,
            bottom:
                widget.attributionVerticalOffset +
                MediaQuery.of(context).padding.bottom,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              child: InkWell(
                borderRadius: BorderRadius.circular(3),
                onTap: () => launchUrl(
                  Uri.parse('https://www.mapbox.com/'),
                  mode: LaunchMode.externalApplication,
                ),
                child: SizedBox(
                  width: 92,
                  height: 32,
                  child: Image.network(
                    _mapboxLogoUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: 'Mapbox',
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text(
                        'Mapbox',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
