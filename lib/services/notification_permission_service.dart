import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionService {
  static final _messaging = FirebaseMessaging.instance;
  static final _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _privateContextRef(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('context');
  }

  static bool isEnabled(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static String statusName(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'authorized',
      AuthorizationStatus.provisional => 'provisional',
      AuthorizationStatus.denied => 'denied',
      AuthorizationStatus.notDetermined => 'not_determined',
    };
  }

  static Future<NotificationSettings> getAndSyncSettings() async {
    final settings = await _messaging.getNotificationSettings();
    await syncSettings(settings);
    return settings;
  }

  static Future<NotificationSettings> requestAndSync() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await syncSettings(settings);
    return settings;
  }

  static Future<void> syncSettings(NotificationSettings settings) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final enabled = isEnabled(settings);
    String? token;
    if (enabled) {
      try {
        token = await _messaging.getToken();
      } catch (_) {
        token = null;
      }
    }
    final privateUpdates = <String, dynamic>{
      'notificationsEnabled': enabled,
      'notificationAuthorizationStatus': statusName(
        settings.authorizationStatus,
      ),
      'notificationStatusUpdatedAt': FieldValue.serverTimestamp(),
      'pushUpdatedAt': FieldValue.serverTimestamp(),
    };

    if (token != null && token.isNotEmpty) {
      privateUpdates['fcmToken'] = token;
    } else {
      privateUpdates['fcmToken'] = FieldValue.delete();
    }

    final batch = _firestore.batch();
    batch.set(
        _privateContextRef(user.uid), privateUpdates, SetOptions(merge: true));
    batch.set(
      _firestore.collection('users').doc(user.uid),
      {
        'fcmToken': FieldValue.delete(),
        'pushUpdatedAt': FieldValue.delete(),
        'notificationsEnabled': FieldValue.delete(),
        'notificationAuthorizationStatus': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}
