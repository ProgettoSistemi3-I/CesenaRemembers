import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:cesena_remembers/presentation/services/shared_position_stream.dart';

void main() {
  group('RecoveringPositionStream', () {
    test('reopens the platform stream after permission is revoked and granted again', () async {
      var permission = LocationPermission.whileInUse;
      var openedStreams = 0;
      final firstStarted = Completer<void>();
      final secondStarted = Completer<void>();
      final firstPlatformStream = StreamController<Position>();
      final secondPlatformStream = StreamController<Position>();
      final receivedPosition = Completer<Position>();

      final source = RecoveringPositionStream(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => permission,
        openPositionStream: () {
          openedStreams++;
          if (openedStreams == 1) {
            firstStarted.complete();
            return firstPlatformStream.stream;
          }
          if (openedStreams == 2) {
            secondStarted.complete();
            return secondPlatformStream.stream;
          }
          throw StateError('Unexpected extra GPS stream');
        },
        retryDelay: const Duration(milliseconds: 20),
      );

      final subscription = source.positions.listen(
        (position) {
          if (!receivedPosition.isCompleted) {
            receivedPosition.complete(position);
          }
        },
        onError: (_) {},
      );

      try {
        await firstStarted.future.timeout(const Duration(seconds: 1));

        // Simulate the platform stream failing after the user revokes GPS.
        permission = LocationPermission.denied;
        firstPlatformStream.addError(StateError('Location permission revoked'));

        // The broadcast listener stays subscribed, but the platform stream
        // must not reopen while the permission remains denied.
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(openedStreams, 1);

        permission = LocationPermission.whileInUse;
        await secondStarted.future.timeout(const Duration(seconds: 1));

        final expectedPosition = Position(
          latitude: 44.1384,
          longitude: 12.2471,
          timestamp: DateTime.utc(2026, 11, 8),
          accuracy: 5,
          altitude: 0,
          altitudeAccuracy: 1,
          heading: 0,
          headingAccuracy: 1,
          speed: 0,
          speedAccuracy: 0,
          isMocked: false,
        );
        secondPlatformStream.add(expectedPosition);

        expect(
          await receivedPosition.future.timeout(const Duration(seconds: 1)),
          expectedPosition,
        );
      } finally {
        await subscription.cancel();
        await source.dispose();
        await firstPlatformStream.close();
        await secondPlatformStream.close();
      }
    });
  });
}
