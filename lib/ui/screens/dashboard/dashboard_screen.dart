import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/battery_gauge.dart';
import '../../widgets/dashboard/charge_suggestion_card.dart';
import '../../widgets/dashboard/quick_map_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const batteryPercent = 0.62; // 0..1 (mock, cámbialo por tu dato real)
    const fullRangeKm = 40;      // autonomía a 100% (ajústalo a tu vehículo)
    final estRangeKm = (batteryPercent * fullRangeKm).round();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(
            children: [
              // Gauge de batería
              const BatteryGauge(percent: batteryPercent),

              const SizedBox(height: 12),

              // Grid de métricas: Voltaje + Autonomía estimada (sin Velocidad)
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
                  const _MetricTile(
                    title: 'Voltaje pack',
                    value: '51.2 V', // coloca tu lectura real
                    icon: Icons.bolt,
                  ),
                  _MetricTile(
                    title: 'Autonomía estimada',
                    value: '$estRangeKm km',
                    icon: Icons.route,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sugerencias de carga (reglas simples)
              const ChargeSuggestionCard(percent: batteryPercent),

              const SizedBox(height: 12),

              // Mapa rápido: tap -> pantalla de Mapa
              QuickMapCard(onTap: () => context.go('/app/mapa')),
            ],
          ),
        ),
      ],
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
    return MetricCard(
      title: title,
      value: value,
      icon: icon,
      onTap: null,
    );
  }
}
