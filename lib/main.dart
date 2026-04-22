import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_controller.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/core/utils/text_utils.dart';

import 'core/auth_wrapper.dart';
import 'core/utils/location_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseStarted = false;
  try {
    await Firebase.initializeApp();
    firebaseStarted = true;
  } catch (error, stackTrace) {
    debugPrint('Firebase startup failed: $error\n$stackTrace');
  }

  if (!firebaseStarted) {
    runApp(const StartupErrorApp());
    return;
  }

  runApp(const MyApp());

  unawaited(_configureNotifications());
}

Future<void> _configureNotifications() async {
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (Platform.isIOS || Platform.isMacOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      await FirebaseMessaging.instance.requestPermission();
    }

    const android = AndroidInitializationSettings('ic_notification');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  } catch (error, stackTrace) {
    debugPrint('Notification startup skipped: $error\n$stackTrace');
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Uygulama baslatilamadi. Lutfen internet baglantinizi kontrol edip tekrar deneyin.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _syncUserPushContext(currentUser);
      }

      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          unawaited(_syncUserPushContext(user));
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
          normalizeNotificationText(notification.title ?? 'Bildirim'),
          normalizeNotificationText(notification.body ?? ''),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              importance: Importance.max,
              priority: Priority.high,
              icon: 'ic_notification',
            ),
            iOS: DarwinNotificationDetails(),
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
    } catch (error, stackTrace) {
      debugPrint('FCM setup skipped: $error\n$stackTrace');
    }
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
            theme: ThemeData(
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFFFF7EA),
                contentTextStyle: const TextStyle(
                  color: Color(0xFF3A1D07),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                actionTextColor: const Color(0xFFB97328),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFEADBC4)),
                ),
              ),
            ),
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
