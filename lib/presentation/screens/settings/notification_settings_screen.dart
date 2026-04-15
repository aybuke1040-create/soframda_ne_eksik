import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  DocumentReference<Map<String, dynamic>> _privateContextRef(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('context');
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          batch.set(_privateContextRef(user.uid), {
            'fcmToken': token,
            'pushUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          batch.set(
            FirebaseFirestore.instance.collection('users').doc(user.uid),
            {
              'fcmToken': FieldValue.delete(),
              'pushUpdatedAt': FieldValue.delete(),
            },
            SetOptions(merge: true),
          );
          await batch.commit();
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
      });

      final message = switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized => 'Bildirim izni verildi.',
        AuthorizationStatus.provisional =>
          'Bildirimler sessiz modda etkinleştirildi.',
        AuthorizationStatus.denied => 'Bildirim izni kapalı görünüyor.',
        _ => 'Bildirim tercihi güncellendi.',
      };

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
                ? 'Bildirim güncellemesi zaman aşımına uğradı. Lütfen tekrar deneyin.'
                : 'Bildirim izni güncellenemedi: $e',
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

  String _statusLabel() {
    switch (_settings?.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return 'Bildirimler açık';
      case AuthorizationStatus.provisional:
        return 'Sessiz izin verildi';
      case AuthorizationStatus.denied:
        return 'Bildirim izni kapalı';
      case AuthorizationStatus.notDetermined:
        return 'İzin henüz verilmedi';
      default:
        return 'Durum bilinmiyor';
    }
  }

  String _statusDescription() {
    switch (_settings?.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return 'Yeni ilanlar, teklifler ve mesajlar için bildirim alabilirsiniz.';
      case AuthorizationStatus.denied:
        return 'Bildirimler kapalı. Uygulama ayarlarından yeniden açabilirsiniz.';
      case AuthorizationStatus.notDetermined:
        return 'Bildirimleri açarak teklif ve mesajları anında görebilirsiniz.';
      default:
        return 'Bildirim tercihinizi bu ekrandan yönetebilirsiniz.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Bildirim Ayarları', 'Notification Settings')),
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
                        _statusLabel(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusDescription(),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _requestPermission,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      _isSaving
                          ? 'Kaydediliyor...'
                          : 'Bildirim İznini Güncelle',
                    ),
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


