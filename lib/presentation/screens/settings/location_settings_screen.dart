import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/presentation/screens/maps/location_picker_screen.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  LocationPermission? _permission;
  Position? _position;
  bool _serviceEnabled = false;
  bool _isLoading = true;
  bool _isSaving = false;

  DocumentReference<Map<String, dynamic>> _privateContextRef(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('context');
  }

  Future<Position?> _resolveBestPosition() async {
    Position? position;

    try {
      position = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      position = current;
    } catch (_) {}

    return position;
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    Position? position;

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      position = await _resolveBestPosition();
    }

    if (position == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await _privateContextRef(user.uid).get();
        final data = snapshot.data();
        final latitude = (data?['latitude'] as num?)?.toDouble();
        final longitude = (data?['longitude'] as num?)?.toDouble();
        if (latitude != null && longitude != null) {
          position = Position(
            longitude: longitude,
            latitude: latitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _serviceEnabled = serviceEnabled;
      _permission = permission;
      _position = position;
      _isLoading = false;
    });
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position? position;
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        position = await _resolveBestPosition();
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && position != null) {
        final batch = FirebaseFirestore.instance.batch();
        batch.set(_privateContextRef(user.uid), {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'locationUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        batch.set(
          FirebaseFirestore.instance.collection('users').doc(user.uid),
          {
            'latitude': FieldValue.delete(),
            'longitude': FieldValue.delete(),
            'locationUpdatedAt': FieldValue.delete(),
          },
          SetOptions(merge: true),
        );
        await batch.commit();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _serviceEnabled = serviceEnabled;
        _permission = permission;
        _position = position;
      });

      final message = position != null
          ? 'Konum bilgisi güncellendi.'
          : 'Konum bilgisi şu an alınamadı. Cihaz konumunu ve interneti kontrol edin.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is TimeoutException
                ? 'Konum güncellemesi zaman aşımına uğradı. Lütfen tekrar deneyin.'
                : 'Konum güncellenemedi: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _permissionLabel() {
    switch (_permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return 'Konum izni açık';
      case LocationPermission.denied:
        return 'Konum izni kapalı';
      case LocationPermission.deniedForever:
        return 'Konum izni kalıcı olarak kapalı';
      case LocationPermission.unableToDetermine:
      default:
        return 'Konum durumu bilinmiyor';
    }
  }

  String _positionLabel() {
    if (_position == null) {
      return 'Henüz kayıtlı bir konum bulunmuyor.';
    }

    return 'Son konum: ${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Konum Ayarları', 'Location Settings')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F6F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE7DDCF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _permissionLabel(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _serviceEnabled
                            ? 'Yakındaki ilanları gösterebilmek için konum bilgisi kullanılır.'
                            : 'Cihaz konum servisi kapalı görünüyor.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _positionLabel(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _requestLocation,
                    icon: const Icon(Icons.my_location_outlined),
                    label: Text(
                      _isSaving ? 'Güncelleniyor...' : 'Konum İznini Güncelle',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Haritayı Test Et'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
                    },
                    icon: const Icon(Icons.location_searching_outlined),
                    label: const Text('Cihaz Konum Ayarlarını Aç'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Uygulama Ayarlarını Aç'),
                  ),
                ),
              ],
            ),
    );
  }
}

