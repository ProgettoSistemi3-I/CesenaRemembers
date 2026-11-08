import 'tour_stop.dart';

class RoutePath {
  const RoutePath({required this.points, this.fromMapbox = false});

  const RoutePath.empty() : points = const [], fromMapbox = false;

  factory RoutePath.straight({
    required GeoPoint origin,
    required GeoPoint destination,
  }) {
    return RoutePath(points: [origin, destination]);
  }

  final List<GeoPoint> points;

  /// True only when points come from the Mapbox Directions API.
  final bool fromMapbox;

  bool get isDrawable => points.length >= 2;
}
