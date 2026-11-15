import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cesena_remembers/domain/entities/tour_stop.dart';
import 'package:cesena_remembers/presentation/controllers/tour_session_controller.dart';
import 'package:cesena_remembers/presentation/services/tour_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

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


    test('restores an active tour after the controller is recreated', () async {
      final availableStops = [
        stop('A', 44.01),
        stop('B', 44.02),
      ];
      final store = TourSessionStore();
      final original = TourSessionController(
        availableStops: availableStops,
        sessionStore: store,
        positionStreamFactory: () => const Stream<Position>.empty(),
      );
      expect(
        await original.startTour(origin: const LatLng(44.0, 12.0)),
        isTrue,
      );
      final expectedStopIds = original.orderedStops.map((item) => item.id).toList();
      original.dispose();

      final restored = TourSessionController(
        availableStops: availableStops,
        sessionStore: store,
        positionStreamFactory: () => const Stream<Position>.empty(),
      );
      addTearDown(restored.dispose);

      expect(await restored.restoreSession(), isTrue);
      expect(restored.isActive, isTrue);
      expect(
        restored.orderedStops.map((item) => item.id).toList(),
        expectedStopIds,
      );
      expect(restored.currentStop?.id, expectedStopIds.first);
      expect(restored.totalElapsedSeconds, greaterThanOrEqualTo(0));

      restored.stopTour();
    });

    test('allows the first upcoming stop to be reordered', () async {
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
      expect(controller.orderedStops.map((item) => item.id), ['B', 'C', 'A']);
      expect(controller.currentStop?.id, 'B');

      controller.reorderUpcomingStops(oldRelativeIndex: 1, newRelativeIndex: 2);
      expect(controller.orderedStops.map((item) => item.id), ['B', 'A', 'C']);
      expect(controller.currentStop?.id, 'B');

      controller.reorderUpcomingStops(oldRelativeIndex: 2, newRelativeIndex: 0);
      expect(controller.orderedStops.map((item) => item.id), ['C', 'B', 'A']);
      expect(controller.currentStop?.id, 'C');

      controller.stopTour();
      expect(controller.status, TourStatus.idle);
      expect(controller.orderedStops, isEmpty);
      expect(controller.totalElapsedSeconds, 0);
    });
  });
}
