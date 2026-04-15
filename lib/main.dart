import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_controller.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';

import 'core/auth_wrapper.dart';
import 'core/utils/location_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(settings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLocaleController _localeController = AppLocaleController();

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
    _setupFCM();
    _localeController.load();
  }

  Future<void> _setupFCM() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _syncUserPushContext(currentUser);
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _syncUserPushContext(user);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

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
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      if (notification == null) {
        return;
      }

      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title ?? 'Bildirim',
        notification.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final requestId = message.data['requestId'];

      if (requestId != null) {
        navigatorKey.currentState?.pushNamed(
          '/requestDetail',
          arguments: requestId,
        );
      }
    });
  }

  Future<void> _syncUserPushContext(User user) async {
    final token = await FirebaseMessaging.instance.getToken();

    final updates = <String, dynamic>{
      'pushUpdatedAt': FieldValue.serverTimestamp(),
    };

    if (token != null && token.isNotEmpty) {
      updates['fcmToken'] = token;
    }

    try {
      final position = await getUserLocation();
      updates['latitude'] = position.latitude;
      updates['longitude'] = position.longitude;
      updates['locationUpdatedAt'] = FieldValue.serverTimestamp();
    } catch (_) {
      // Konum izni verilmemisse token kaydi yine de devam etsin.
    }

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_privateContextRef(user.uid), updates, SetOptions(merge: true));
    batch.set(
      FirebaseFirestore.instance.collection('users').doc(user.uid),
      {
        'fcmToken': FieldValue.delete(),
        'pushUpdatedAt': FieldValue.delete(),
        'latitude': FieldValue.delete(),
        'longitude': FieldValue.delete(),
        'locationUpdatedAt': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            locale: const Locale('tr'),
            supportedLocales: AppLocaleController.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
