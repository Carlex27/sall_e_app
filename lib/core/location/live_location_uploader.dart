import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/fs_paths.dart';

class LiveLocationUploader {
  LiveLocationUploader._();
  static final LiveLocationUploader instance = LiveLocationUploader._();

  final _db = FirebaseFirestore.instance;

  StreamSubscription<Position>? _sub;
  String? _deviceId;
  bool get isRunning => _sub != null;

  /// Inicia el envío en vivo para un deviceId.
  Future<void> start({required String deviceId}) async {
    if (_sub != null && _deviceId == deviceId) return; // ya está corriendo para ese device
    await _ensurePermission();

    // Si ya había uno activo para otro device, detenlo.
    await stop();

    _deviceId = deviceId;

    // Configuramos un stream eficiente: alta precisión y envío solo si se mueve >30 m.
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30, // metros
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) => _uploadPosition(pos),
      onError: (e) => _log('Location error: $e'),
      cancelOnError: false,
    );

    // Además, subimos un punto inmediato para tenerlo al instante.
    try {
      final first = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _uploadPosition(first);
    } catch (_) {}
  }

  /// Detiene el envío en vivo.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _deviceId = null;
  }

  Future<void> _uploadPosition(Position pos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final deviceId = _deviceId;
    if (uid == null || deviceId == null) return;

    final doc = _db.doc(FsPaths.deviceLiveLocation(deviceId));
    await doc.set({
      'lat': pos.latitude,
      'lng': pos.longitude,
      'accuracy': pos.accuracy,
      'byUid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente.');
    }
  }

  void _log(Object o) {
    // print(o); // si quieres ver logs
  }
}
