import 'package:cloud_firestore/cloud_firestore.dart';
import 'fs_paths.dart';

class DeviceRepo {
  final _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchStatus(String deviceId) {
    return _db.doc(FsPaths.deviceStatus(deviceId)).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchLiveLocation(String deviceId) {
    return _db.doc(FsPaths.deviceLiveLocation(deviceId)).snapshots();
  }
}
