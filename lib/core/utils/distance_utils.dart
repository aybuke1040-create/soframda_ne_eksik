import 'package:geolocator/geolocator.dart';

double calculateDistance(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  return Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      ) /
      1000;
}
