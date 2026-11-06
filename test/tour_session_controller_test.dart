import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:cesena_remembers/domain/entities/tour_stop.dart';
import 'package:cesena_remembers/presentation/controllers/tour_session_controller.dart';

void main() {
  group('TourSessionController elapsed time', () {
    TourStop makeStop(String id, double latitude) => TourStop(
      id: id,
      name: id,
      type: 'monument',
      period: '1944',
      description: 'Test stop',
      position: GeoPoint(latitude: latitude, longitude: 12.0),
      questions: const [],
    );

    test('total time keeps counting during quizzes and an already-reached next stop', () async {
      const origin = LatLng(44.0, 12.0);
      final controller = TourSessionController(
        availableStops: [
          makeStop('first', 44.0),
          makeStop('second', 44.00001),
        ],
        originResolver: () async => origin,
        positionStreamFactory: () => const Stream<Position>.empty(),
      );
      addTearDown(controller.dispose);

      expect(await controller.startTour(), isTrue);
      expect(controller.status, TourStatus.arrived);
      expect(controller.elapsedSeconds, 0);

      await Future<void>.delayed(const Duration(milliseconds: 1150));
      final elapsedDuringQuiz = controller.totalElapsedSeconds;
      expect(elapsedDuringQuiz, greaterThanOrEqualTo(1));
      expect(controller.elapsedSeconds, 0);

      expect(controller.advanceToNextStop(), isTrue);
      expect(controller.status, TourStatus.arrived);
      await Future<void>.delayed(const Duration(milliseconds: 1150));

      expect(controller.totalElapsedSeconds, greaterThan(elapsedDuringQuiz));
      expect(controller.elapsedSeconds, 0);
    });
  });
}
