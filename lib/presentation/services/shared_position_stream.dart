import 'package:geolocator/geolocator.dart';

/// Un'unica sorgente broadcast evita di aprire due flussi GPS di navigazione.
/// Il filtraggio a 10 m riduce le letture senza compromettere la precisione del tour.
class SharedPositionStream {
  SharedPositionStream._();

  static final Stream<Position> positions = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).asBroadcastStream();
}
