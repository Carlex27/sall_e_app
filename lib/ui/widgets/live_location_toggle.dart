import 'package:flutter/material.dart';
import 'package:sall_e_app/core/location/live_location_uploader.dart';


class LiveLocationToggle extends StatefulWidget {
  const LiveLocationToggle({super.key, required this.deviceId});
  final String deviceId;

  @override
  State<LiveLocationToggle> createState() => _LiveLocationToggleState();
}

class _LiveLocationToggleState extends State<LiveLocationToggle> {
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _sharing = LiveLocationUploader.instance.isRunning;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(Icons.share_location, color: cs.primary),
        title: const Text('Compartir ubicación al vehículo'),
        subtitle: const Text('Usa el GPS de este teléfono para actualizar la ubicación en vivo.'),
        trailing: Switch(
          value: _sharing,
          onChanged: (v) async {
            setState(() => _sharing = v);
            if (v) {
              await LiveLocationUploader.instance.start(deviceId: widget.deviceId);
            } else {
              await LiveLocationUploader.instance.stop();
            }
          },
        ),
      ),
    );
  }
}
