import 'package:geolocator/geolocator.dart';

class UserLocationException implements Exception {
  final String message;

  const UserLocationException(this.message);

  @override
  String toString() => message;
}

Future<Position> getUserLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw const UserLocationException(
      'Konum servisin kapalı görünüyor. İlanını yayınlamak için lütfen telefon ayarlarından konumu açıp tekrar dene.',
    );
  }

  var permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    throw const UserLocationException(
      'Konum izni verilmedi. İlanını yayınlamak için konum iznine izin verip tekrar dene.',
    );
  }

  if (permission == LocationPermission.deniedForever) {
    throw const UserLocationException(
      'Konum izni kalıcı olarak kapalı. Lütfen telefon ayarlarından Ben Yaparım için konum iznini açıp tekrar dene.',
    );
  }

  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (_) {
    throw const UserLocationException(
      'Konumun alınamadı. Lütfen konum servisinin açık olduğundan emin olup tekrar dene.',
    );
  }
}
