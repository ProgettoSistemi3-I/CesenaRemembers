import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:cesena_remembers/domain/entities/tour_stop.dart';
import 'package:cesena_remembers/presentation/controllers/tour_session_controller.dart';

void main() {
  TourStop stop(String id, double latitude) => TourStop(
    id: id,
    name: id,
    type: 'monument',
    period: '1944',
    description: 'Test stop',
    position: GeoPoint(latitude: latitude, longitude: 12.0),
    questions: const [],
  );

  group('TourSessionController state transitions', () {
    test('does not start a tour without available stops', () async {
      final controller = TourSessionController(
        availableStops: const [],
        originResolver: () async => const LatLng(44.0, 12.0),
        positionStreamFactory: () => const Stream<Position>.empty(),
      );
      addTearDown(controller.dispose);

      expect(await controller.startTour(), isFalse);
      expect(controller.status, TourStatus.idle);
      expect(controller.hasStops, isFalse);
      expect(controller.orderedStops, isEmpty);
    });

    test('keeps the active stop fixed while allowing upcoming stops to be reordered', () async {
      final controller = TourSessionController(
        availableStops: [
          stop('A', 44.01),
          stop('B', 44.02),
          stop('C', 44.03),
        ],
        originResolver: () async => const LatLng(44.0, 12.0),
        positionStreamFactory: () => const Stream<Position>.empty(),
      );
      addTearDown(controller.dispose);

      expect(await controller.startTour(), isTrue);
      expect(controller.status, TourStatus.running);
      expect(controller.currentStop?.id, 'A');

      controller.reorderUpcomingStops(oldRelativeIndex: 0, newRelativeIndex: 2);
      expect(controller.orderedStops.map((item) => item.id), ['A', 'B', 'C']);

      controller.reorderUpcomingStops(oldRelativeIndex: 1, newRelativeIndex: 2);
      expect(controller.orderedStops.map((item) => item.id), ['A', 'C', 'B']);
      expect(controller.currentStop?.id, 'A');

      controller.stopTour();
      expect(controller.status, TourStatus.idle);
      expect(controller.orderedStops, isEmpty);
      expect(controller.totalElapsedSeconds, 0);
    });
  });
}
