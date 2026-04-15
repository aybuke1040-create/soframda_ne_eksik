import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng selected = const LatLng(41.0082, 28.9784);
  GoogleMapController? _mapController;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position? position;

      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      try {
        final current = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        position = current;
      } catch (_) {}

      if (position != null) {
        selected = LatLng(position.latitude, position.longitude);
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selected, 15),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selected,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(selected, 15),
              );
            },
            onTap: (latLng) {
              setState(() {
                selected = latLng;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selected,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLocating)
            const Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Konumun bulunuyor...'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selected);
              },
              child: const Text('Konumu Seç'),
            ),
          ),
        ],
      ),
    );
  }
}
