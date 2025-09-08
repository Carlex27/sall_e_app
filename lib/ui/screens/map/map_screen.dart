import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/user_vehicle_repo.dart';
import '../../../data/device_repo.dart';
import '../../../core/location/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = Completer<GoogleMapController>();
  LatLng _camera = const LatLng(19.4326, -99.1332); // CDMX
  LatLng? _marker;
  String? _statusMsg;

  @override
  Widget build(BuildContext context) {
    final vehicles = UserVehicleRepo();
    final devices = DeviceRepo();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      stream: vehicles.watchPrimaryVehicle(),
      builder: (context, vehSnap) {
        if (!vehSnap.hasData) return const Center(child: CircularProgressIndicator());
        final veh = vehSnap.data;
        if (veh == null || !veh.exists) {
          return _CenteredText('No encontré un vehículo para ${FirebaseAuth.instance.currentUser?.email ?? ''}');
        }
        final v = veh.data()!;
        final deviceId = (v['deviceId'] as String?) ?? '';
        if (deviceId.isEmpty) return const _CenteredText('Este vehículo no tiene deviceId ligado.');

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: devices.watchLiveLocation(deviceId),
          builder: (context, locSnap) {
            LatLng? live;
            String? msg;
            if (locSnap.hasData && locSnap.data!.exists) {
              final d = locSnap.data!.data()!;
              final lat = (d['lat'] as num?)?.toDouble();
              final lng = (d['lng'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                live = LatLng(lat, lng);
                msg = 'Ubicación del vehículo';
              }
            }
            // Fallback a ubicación del teléfono si no hay liveLocation
            if (live == null) {
              msg = 'Sin ubicación del vehículo aún. Mostrando tu ubicación.';
            }
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final target = live ?? _camera;
              if (_marker != target) {
                _marker = target;
                _camera = target;
                if (_mapController.isCompleted) {
                  final c = await _mapController.future;
                  await c.animateCamera(CameraUpdate.newLatLngZoom(target, live != null ? 15 : 12));
                }
                setState(() {
                  _statusMsg = msg;
                });
              }
            });

            return FutureBuilder<LatLng?>(
              future: live != null ? Future.value(live) : _getFastLocation(),
              builder: (_, __) {
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(target: _camera, zoom: 12),
                      myLocationEnabled: live == null, // sólo si usamos la del teléfono
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (c) => _mapController.complete(c),
                      markers: _marker == null
                          ? {}
                          : {
                        Marker(
                          markerId: MarkerId(live != null ? 'veh' : 'me'),
                          position: _marker!,
                          infoWindow: InfoWindow(title: live != null ? 'Vehículo' : 'Tú'),
                        )
                      },
                    ),

                    if (_statusMsg != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: _ChipInfo(text: _statusMsg!),
                      ),

                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          final c = await _mapController.future;
                          await c.animateCamera(CameraUpdate.newLatLngZoom(_marker ?? _camera, 15));
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text('Centrar'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<LatLng?> _getFastLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      final ll = LatLng(pos.latitude, pos.longitude);
      _camera = ll;
      return ll;
    } catch (_) {
      return null;
    }
  }
}

class _CenteredText extends StatelessWidget {
  const _CenteredText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24), child: Text(text, textAlign: TextAlign.center),
  ));
}

class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cs.surface.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.info_outline, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(text)),
      ]),
    );
  }
}
