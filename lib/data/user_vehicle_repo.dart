import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserVehicleRepo {
  final _db = FirebaseFirestore.instance;

  /// Devuelve el PRIMER vehículo del usuario (ownerUid == uid).
  Stream<DocumentSnapshot<Map<String, dynamic>>?> watchPrimaryVehicle() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db
        .collection('vehicles')
        .where('ownerUid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((q) => q.docs.isNotEmpty ? q.docs.first : null);
  }
}
