import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/user_vehicle_repo.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = UserVehicleRepo();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      stream: repo.watchPrimaryVehicle(),
      builder: (context, vehSnap) {
        if (!vehSnap.hasData) return const Center(child: CircularProgressIndicator());
        final veh = vehSnap.data;
        if (veh == null || !veh.exists) {
          return Center(child: Text('No encontré vehículo para ${FirebaseAuth.instance.currentUser?.email ?? ''}.'));
        }
        final v = veh.data()!;
        final name = v['name'] as String? ?? 'Vehículo';
        final vin = v['vin'] as String? ?? '—';
        final year = (v['year'] as num?)?.toInt();
        final deviceId = v['deviceId'] as String? ?? '—';
        final cap = (v['capacity_kWh'] as num?)?.toDouble();
        final eff = (v['km_per_kWh'] as num?)?.toDouble();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Tile(title: 'Nombre', value: name, icon: Icons.directions_car),
            _Tile(title: 'Año', value: year?.toString() ?? '—', icon: Icons.calendar_today),
            _Tile(title: 'VIN / Placa', value: vin, icon: Icons.qr_code_2),
            _Tile(title: 'Device ID', value: deviceId, icon: Icons.memory),
            const SizedBox(height: 8),
            _SectionHeader('Parámetros de autonomía'),
            _Tile(title: 'Capacidad', value: cap != null ? '${cap.toStringAsFixed(1)} kWh' : '—', icon: Icons.battery_full),
            _Tile(title: 'Eficiencia', value: eff != null ? '${eff.toStringAsFixed(1)} km/kWh' : '—', icon: Icons.route),
            const SizedBox(height: 8),
            _SectionHeader('Estado del dispositivo'),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.doc('devices/$deviceId').snapshots(),
              builder: (_, devSnap) {
                final last = devSnap.data?.data()?['lastSeenAt'] as Timestamp?;
                final txt = last != null ? last.toDate().toLocal().toString() : 'Sin actividad reciente';
                return _Tile(title: 'Última lectura', value: txt, icon: Icons.access_time);
              },
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.value, this.icon});
  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
