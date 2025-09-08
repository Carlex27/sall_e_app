import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Pide permisos si es necesario y devuelve la posición actual.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

Future<LatLng?> _getFastLocation() async {
  // 1) last known: casi instantánea si el SO tiene cache
  final last = await Geolocator.getLastKnownPosition();
  if (last != null) return LatLng(last.latitude, last.longitude);

  // 2) fallback rápido: con timeout corto
  try {
    final quick = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 3),
    );
    return LatLng(quick.latitude, quick.longitude);
  } catch (_) {
    return null;
  }
}
