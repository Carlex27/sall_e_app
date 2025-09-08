import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sall_e_app/ui/widgets/live_location_toggle.dart';

import '../../../data/user_vehicle_repo.dart';
import '../../../data/device_repo.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/battery_gauge.dart';
import '../../widgets/dashboard/charge_suggestion_card.dart';
import '../../widgets/dashboard/quick_map_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = UserVehicleRepo();
    final devices = DeviceRepo();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      stream: vehicles.watchPrimaryVehicle(),
      builder: (context, vehSnap) {
        if (!vehSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final veh = vehSnap.data;
        if (veh == null || !veh.exists) {
          return _EmptyState(email: FirebaseAuth.instance.currentUser?.email ?? 'tu usuario');
        }
        final v = veh.data()!;
        final deviceId = (v['deviceId'] as String?) ?? '';

        if (deviceId.isEmpty) {
          return const Center(child: Text('Este vehículo no tiene deviceId ligado.'));
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: devices.watchStatus(deviceId),
          builder: (context, stSnap) {
            if (!stSnap.hasData || !stSnap.data!.exists) {
              return const Center(child: Text('Sin lecturas aún…'));
            }
            final s = stSnap.data!.data()!;
            final soc = (s['soc'] as num?)?.toDouble() ?? 0.0;       // 0..100
            final vPack = (s['v_pack'] as num?)?.toDouble();         // volts
            final autonomyKm = (s['autonomy_km'] as num?)?.toInt();  // km

            final percent = (soc / 100).clamp(0.0, 1.0);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      // Gauge de batería
                      BatteryGauge(percent: percent),

                      const SizedBox(height: 12),

                      // Grid de métricas: Voltaje + Autonomía
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                        children: [
                          _MetricTile(
                            title: 'Voltaje pack',
                            value: vPack != null ? '${vPack.toStringAsFixed(1)} V' : 'N/A',
                            icon: Icons.bolt,
                          ),
                          _MetricTile(
                            title: 'Autonomía estimada',
                            value: autonomyKm != null ? '$autonomyKm km' : 'N/A',
                            icon: Icons.route,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Sugerencias de carga (tu lógica después)
                      ChargeSuggestionCard(percent: percent),

                      const SizedBox(height: 12),

                      // Mapa rápido: tap -> pantalla de Mapa
                      QuickMapCard(
                        onTap: () => context.go('/app/mapa'),
                        // si tu widget lo soporta, pásale deviceId para enlazar ubicación
                        deviceId: deviceId,
                      ),
                      LiveLocationToggle(deviceId: deviceId),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value, this.icon});
  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return MetricCard(title: title, value: value, icon: icon, onTap: null);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No encontré un vehículo para $email.\nCrea "vehicles/{vehId}" con ownerUid y deviceId.'),
    );
  }
}
