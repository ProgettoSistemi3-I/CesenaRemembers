import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/entities/tour_stop.dart';
import 'package:cesena_remembers/domain/services/tour_route_planner.dart';

void main() {
  TourStop stop(String id, double latitude, double longitude) => TourStop(
    id: id,
    name: id,
    type: 'monument',
    period: '1944',
    description: 'Test stop',
    position: GeoPoint(latitude: latitude, longitude: longitude),
    questions: const [],
  );

  group('TourRoutePlanner', () {
    const planner = TourRoutePlanner();

    test('chooses the nearest remaining stop at every step', () {
      final input = [
        stop('B', 44.003, 12.0),
        stop('C', 44.001, 12.001),
        stop('A', 44.001, 12.0),
      ];

      final result = planner.sortNearestNeighbor(
        origin: const GeoPoint(latitude: 44.0, longitude: 12.0),
        stops: input,
      );

      expect(result.map((item) => item.id), ['A', 'C', 'B']);
    });

    test('does not mutate the caller-owned list', () {
      final input = [
        stop('B', 44.003, 12.0),
        stop('A', 44.001, 12.0),
      ];

      planner.sortNearestNeighbor(
        origin: const GeoPoint(latitude: 44.0, longitude: 12.0),
        stops: input,
      );

      expect(input.map((item) => item.id), ['B', 'A']);
    });

    test('returns an empty list for an empty tour', () {
      expect(
        planner.sortNearestNeighbor(
          origin: const GeoPoint(latitude: 44.0, longitude: 12.0),
          stops: const [],
        ),
        isEmpty,
      );
    });

    test('returns every stop exactly once', () {
      final input = [
        stop('A', 44.001, 12.0),
        stop('B', 44.002, 12.0),
        stop('C', 44.003, 12.0),
      ];

      final result = planner.sortNearestNeighbor(
        origin: const GeoPoint(latitude: 44.0, longitude: 12.0),
        stops: input,
      );

      expect(result, hasLength(input.length));
      expect(result.map((item) => item.id).toSet(), {'A', 'B', 'C'});
    });
  });
}
