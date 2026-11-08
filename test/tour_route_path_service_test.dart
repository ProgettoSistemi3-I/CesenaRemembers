import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/entities/route_path.dart';
import 'package:cesena_remembers/domain/entities/tour_stop.dart';
import 'package:cesena_remembers/domain/repositories/route_directions_repository.dart';
import 'package:cesena_remembers/domain/services/tour_route_path_service.dart';

class _FakeDirectionsRepository implements RouteDirectionsRepository {
  _FakeDirectionsRepository({this.result, this.error});

  final RoutePath? result;
  final Object? error;
  int calls = 0;

  @override
  Future<RoutePath> getWalkingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    calls++;
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  const origin = GeoPoint(latitude: 44.1, longitude: 12.2);
  const destination = GeoPoint(latitude: 44.2, longitude: 12.3);
  const stop = TourStop(
    id: 'rocca',
    name: 'Rocca',
    type: 'monument',
    period: '1944',
    description: 'Test',
    position: destination,
    questions: [],
  );

  group('TourRoutePathService', () {
    test('returns a drawable route supplied by the directions repository', () async {
      const route = RoutePath(points: [origin, destination]);
      final repository = _FakeDirectionsRepository(result: route);
      final service = TourRoutePathService(directions: repository);

      final result = await service.buildCurrentLegPath(
        origin: origin,
        destination: stop,
      );

      expect(result, same(route));
      expect(repository.calls, 1);
    });

    test('falls back to a straight line when the provider returns no drawable path', () async {
      final repository = _FakeDirectionsRepository(result: const RoutePath.empty());
      final service = TourRoutePathService(directions: repository);

      final result = await service.buildCurrentLegPath(
        origin: origin,
        destination: stop,
      );

      expect(result.points, [origin, destination]);
      expect(result.isDrawable, isTrue);
    });

    test('falls back to a straight line when the provider throws', () async {
      final repository = _FakeDirectionsRepository(error: StateError('offline'));
      final service = TourRoutePathService(directions: repository);

      final result = await service.buildCurrentLegPath(
        origin: origin,
        destination: stop,
      );

      expect(result.points, [origin, destination]);
      expect(result.isDrawable, isTrue);
    });
  });
}
