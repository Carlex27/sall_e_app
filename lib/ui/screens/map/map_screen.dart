import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/location/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
      final map = await _controller.future;
      await map.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 16));
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _recenter() async {
    if (_currentLatLng == null) return _loadLocation();
    final map = await _controller.future;
    await map.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 16));
  }

  @override
  Widget build(BuildContext context) {
    final initial = _currentLatLng ?? const LatLng(19.4326, -99.1332); // CDMX fallback

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: initial, zoom: 12),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
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
        ),

        // Error overlay si aplica
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

        // Botón de recentrar
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _recenter,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
