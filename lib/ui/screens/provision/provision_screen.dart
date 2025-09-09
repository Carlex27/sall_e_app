// lib/ui/screens/provision/provision_screen.dart
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:sall_e_app/core/wifi/provisioning_service.dart';
import 'package:wifi_iot/wifi_iot.dart'; // opcional Android



class ProvisionScreen extends StatefulWidget {
  const ProvisionScreen({super.key});
  @override
  State<ProvisionScreen> createState() => _ProvisionScreenState();

}

class _ProvisionScreenState extends State<ProvisionScreen> {
  final _ssidCtrl = TextEditingController(); // SSID al que se conectará el ESP (tu hotspot o tu WiFi)
  final _passCtrl = TextEditingController();
  String _msg = '1) Enciende el hotspot o identifica tu Wi-Fi.\n2) Conéctate al AP del ESP (SALLE-setup-XXXX).\n3) Regresa y toca "Enviar".';

  @override
  void dispose() { _ssidCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _openWiFiSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  Future<void> _send() async {
    setState(() => _msg = 'Enviando credenciales...');
    final ok = await ProvisioningService.provision(
      ssid: _ssidCtrl.text.trim(),
      pass: _passCtrl.text,
    ).catchError((e) {
      setState(() => _msg = 'Error: $e');
      return false;
    });
    if (ok) {
      setState(() => _msg = 'OK. El ESP se reiniciará y conectará.\nVuelve a tu internet normal y verifica el Dashboard.');
    } else {
      setState(() => _msg = 'Falló el envío. Asegúrate de estar conectado al AP del ESP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Wi-Fi del ESP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(_msg),
            const SizedBox(height: 16),
            TextField(controller: _ssidCtrl, decoration: const InputDecoration(labelText: 'SSID (hotspot o Wi-Fi)'),),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _openWiFiSettings, icon: const Icon(Icons.wifi), label: const Text('Abrir ajustes Wi-Fi')),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send), label: const Text('Enviar al ESP')),
          ],
        ),
      ),
    );
  }
}
