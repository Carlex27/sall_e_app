import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ficha del vehículo (EV)
        _SectionCard(
          title: 'Datos del vehículo',
          children: const [
            _KV('Modelo del vehículo', 'OS-CAR v1 (Eléctrico)'),
            _KV('Número de serie / VIN', 'SLE-2025-001-ABC123'),
            _KV('Año de fabricación', '2025'),
          ],
        ),
        const SizedBox(height: 12),

        // Propietario / Compra
        _SectionCard(
          title: 'Propietario y compra',
          children: const [
            _KV('Nombre del comprador / usuario actual', 'Carlos Ocampo'),
            _KV('Dirección / ciudad de compra', 'Acapulco, Gro.'),
            _KV('Fecha de adquisición', '05 Ago 2025'),
          ],
        ),
        const SizedBox(height: 12),

        // Mantenimiento (último / próximo)
        _SectionCard(
          title: 'Mantenimiento',
          children: const [
            _KV('Último servicio realizado', '10 Ago 2025 – Taller SALL‑E\nDetalle: Revisión general, ajuste de frenos'),
            _KV('Próximo servicio recomendado', '10 Nov 2025 (lo que ocurra primero)'),
          ],
        ),
        const SizedBox(height: 12),

        // Garantía
        _SectionCard(
          title: 'Garantía',
          children: const [
            _KV('Vigencia', 'xx meses '),
          ],
        ),
        const SizedBox(height: 12),

        // Facturación / Documentos
        _SectionCard(
          title: 'Facturación',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long),
              title: const Text('Ver facturas'),
              subtitle: const Text('Consulta o descarga tus documentos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navegar a detalle/listado de facturas o abrir PDF desde backend
                // context.go('/app/facturas'); // si luego creas esa ruta
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Cerrar sesión (al final)
        FilledButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

/// ------- Widgets de apoyo -------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ..._withDividers(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.isEmpty) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(const Divider(height: 16));
      }
    }
    return out;
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(k,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: onVar)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Text(v, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
