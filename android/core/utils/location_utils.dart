import 'package:geolocator/geolocator.dart';

Future<Position> getUserLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

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
