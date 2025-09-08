import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/location/location_service.dart';

class QuickMapCard extends StatefulWidget {
  const QuickMapCard({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  State<QuickMapCard> createState() => _QuickMapCardState();
}

class _QuickMapCardState extends State<QuickMapCard> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      setState(() => _currentLatLng = LatLng(pos.latitude, pos.longitude));
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLatLng!, 15),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial = _currentLatLng ?? const LatLng(19.4326, -99.1332); // CDMX fallback

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  liteModeEnabled: true,
                  initialCameraPosition: CameraPosition(target: initial, zoom: 12),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  onMapCreated: (c) => _controller.complete(c),
                  markers: _currentLatLng == null
                      ? {}
                      : {
                    Marker(
                      markerId: const MarkerId('me'),
                      position: _currentLatLng!,
                      infoWindow: const InfoWindow(title: 'Tu ubicación'),
                    )
                  },
                  onTap: (_) => widget.onTap?.call(),
                ),
              ),

              // Etiqueta
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: cs.primary),
                      const SizedBox(width: 6),
                      const Text('Ubicación rápida'),
                    ],
                  ),
                ),
              ),

              // CTA
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.icon(
                  onPressed: widget.onTap,
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Abrir mapa'),
                ),
              ),

              // Mensaje de error (si aplica)
              if (_error != null)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.35),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
