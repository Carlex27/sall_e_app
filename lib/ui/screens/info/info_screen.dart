import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sall_e_app/core/wifi/provisioning_service.dart';
import 'package:sall_e_app/ui/screens/provision/provision_screen.dart';
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
            const SizedBox(height: 8),
            _SectionHeader('Configurar Wi-Fi del ESP'),
            const ProvisionCard(), // 👈 Nueva tarjeta dentro de InfoScreen

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

class ProvisionCard extends StatefulWidget {
  const ProvisionCard({super.key});

  @override
  State<ProvisionCard> createState() => _ProvisionCardState();
}

class _ProvisionCardState extends State<ProvisionCard> {
  final _ssid = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  String? _hint; // mensajes de estado

  @override
  void dispose() {
    _ssid.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _openWiFiSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  Future<void> _checkESP() async {
    setState(() { _busy = true; _hint = 'Buscando ESP en 192.168.4.1…'; });
    try {
      final st = await ProvisioningService.status();
      setState(() => _hint = 'ESP en modo ${st['mode']} (AP: ${st['apSsid'] ?? 'SALLE-setup-XXXX'})');
    } catch (e) {
      setState(() => _hint = 'No respondio el ESP. Conéctate al AP: SALLE-setup-XXXX');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final ssid = _ssid.text.trim();
    final pass = _pass.text;
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el SSID')));
      return;
    }
    setState(() { _busy = true; _hint = 'Enviando credenciales al ESP…'; });
    try {
      final ok = await ProvisioningService.provision(ssid: ssid, pass: pass);
      if (ok) {
        setState(() => _hint = 'OK. El ESP se reiniciará y conectará a "$ssid". Vuelve a tu Internet normal y revisa el Dashboard.');
      } else {
        setState(() => _hint = 'Falló el envío. Asegúrate de estar conectado al AP del ESP.');
      }
    } catch (e) {
      setState(() => _hint = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('1) Conéctate al AP del ESP (SALLE-setup-XXXX).  2) Escribe tu SSID/clave.  3) Enviar.'),
            const SizedBox(height: 8),
            TextField(
              controller: _ssid,
              decoration: const InputDecoration(labelText: 'SSID (tu hotspot o Wi-Fi)'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _openWiFiSettings,
                icon: const Icon(Icons.wifi),
                label: const Text('Abrir ajustes Wi-Fi'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _checkESP,
                icon: const Icon(Icons.search),
                label: const Text('Probar conexión al ESP'),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _send,
                icon: const Icon(Icons.send),
                label: const Text('Enviar al ESP'),
              ),
            ]),
            if (_hint != null) ...[
              const SizedBox(height: 8),
              Text(_hint!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
