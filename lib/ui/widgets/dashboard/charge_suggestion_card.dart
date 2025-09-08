import 'package:flutter/material.dart';

class ChargeSuggestionCard extends StatelessWidget {
  const ChargeSuggestionCard({super.key, required this.percent});

  final double percent; // 0..1

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final advice = _buildAdvice(percent);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: advice.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(advice.icon, color: advice.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sugerencia de carga',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    advice.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nivel actual: ${(percent.clamp(0.0, 1.0) * 100).round()}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ChargeAdvice _buildAdvice(double p) {
    final pct = p.clamp(0.0, 1.0);
    // Reglas simples de ejemplo; luego puedes reemplazar con
    // lógica real (historial, costo-kWh, hábitos, calendario, etc.)
    if (pct <= 0.20) {
      return _ChargeAdvice(
        message:
        'Nivel bajo. Se recomienda conectar a la carga lo antes posible para evitar quedar por debajo del 10%.',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFD32F2F), // rojo
      );
    } else if (pct <= 0.40) {
      return _ChargeAdvice(
        message:
        'Nivel moderado. Considera cargar pronto, idealmente en horarios de menor demanda eléctrica nocturna.',
        icon: Icons.battery_alert,
        color: const Color(0xFFF57C00), // ámbar
      );
    } else if (pct >= 0.85) {
      return _ChargeAdvice(
        message:
        'Nivel alto. No es necesario cargar ahora; evita ciclos innecesarios para prolongar la vida de la batería.',
        icon: Icons.check_circle,
        color: const Color(0xFF2E7D32), // verde
      );
    } else {
      return _ChargeAdvice(
        message:
        'Nivel saludable. Puedes seguir usando el vehículo y planear una carga por la noche si lo requieres mañana.',
        icon: Icons.battery_charging_full,
        color: const Color(0xFF1976D2), // azul
      );
    }
  }
}

class _ChargeAdvice {
  final String message;
  final IconData icon;
  final Color color;
  _ChargeAdvice({required this.message, required this.icon, required this.color});
}
