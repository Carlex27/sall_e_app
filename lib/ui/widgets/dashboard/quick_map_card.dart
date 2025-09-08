import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/location/location_service.dart';

class QuickMapCard extends StatefulWidget {
  const QuickMapCard({super.key, this.onTap, this.deviceId});

  final VoidCallback? onTap;
  /// Si se proporciona, se lee Firestore: devices/{deviceId}/liveLocation/current
  final String? deviceId;

  @override
  State<QuickMapCard> createState() => _QuickMapCardState();
}

class _QuickMapCardState extends State<QuickMapCard> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;    // lo que mostramos (liveLocation o fallback del teléfono)
  LatLng? _lastAnimatedTo;   // para no animar la cámara en bucle
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fallback al GPS del teléfono (rápido) para tener algo en pantalla
    _loadDeviceFallbackLocation();
  }

  Future<void> _loadDeviceFallbackLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentLatLng = ll);
      _animateTo(ll, zoom: 12);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _animateTo(LatLng target, {double zoom = 15}) async {
    try {
      final c = await _controller.future;
      final shouldMove = _lastAnimatedTo == null ||
          (_lastAnimatedTo!.latitude - target.latitude).abs() > 1e-5 ||
          (_lastAnimatedTo!.longitude - target.longitude).abs() > 1e-5;
      if (shouldMove) {
        await c.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
        _lastAnimatedTo = target;
      }
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fallback = _currentLatLng ?? const LatLng(19.4326, -99.1332); // CDMX

    // Si hay deviceId, conectamos a Firestore; si no, render normal con fallback local
    final Widget map = widget.deviceId == null
        ? _buildMap(fallback)
        : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .doc('devices/${widget.deviceId}/liveLocation/current')
          .snapshots(),
      builder: (context, snap) {
        LatLng target = fallback;
        if (snap.hasData && snap.data!.exists) {
          final d = snap.data!.data()!;
          final lat = (d['lat'] as num?)?.toDouble();
          final lng = (d['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            target = LatLng(lat, lng);
            // Programamos animación después del frame para no hacer side effects en build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animateTo(target, zoom: 15);
            });
          }
        }
        // actualizamos marker mostrado (sin setState: derive de 'target')
        return _buildMap(target);
      },
    );

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
              ClipRRect(borderRadius: BorderRadius.circular(16), child: map),

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
                      Text(widget.deviceId == null ? 'Ubicación rápida' : 'Ubicación del vehículo'),
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

  Widget _buildMap(LatLng target) {
    return GoogleMap(
      liteModeEnabled: true,
      initialCameraPosition: CameraPosition(target: target, zoom: 12),
      myLocationEnabled: widget.deviceId == null, // si es vehículo, no mostramos "mi ubicación"
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (c) => _controller.complete(c),
      markers: {
        Marker(
          markerId: MarkerId(widget.deviceId ?? 'me'),
          position: target,
          infoWindow: InfoWindow(title: widget.deviceId == null ? 'Tu ubicación' : 'Vehículo'),
        )
      },
      onTap: (_) => widget.onTap?.call(),
    );
  }
}
