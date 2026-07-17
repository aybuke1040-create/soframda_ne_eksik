import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/app_navigator.dart';
import 'package:soframda_ne_eksik/presentation/screens/buy_credits_screen.dart';

class LowCreditPromptObserver extends StatefulWidget {
  const LowCreditPromptObserver({required this.child, super.key});

  final Widget child;

  @override
  State<LowCreditPromptObserver> createState() =>
      _LowCreditPromptObserverState();
}

class _LowCreditPromptObserverState extends State<LowCreditPromptObserver> {
  static const int _lowCreditThreshold = 20;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _creditSubscription;
  String? _activeUserId;
  int? _previousCredit;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          _watchUserCredit,
        );
  }

  void _watchUserCredit(User? user) {
    if (_activeUserId == user?.uid) return;

    _creditSubscription?.cancel();
    _creditSubscription = null;
    _activeUserId = user?.uid;
    _previousCredit = null;

    if (user == null) return;

    _creditSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      final credit = (snapshot.data()?['credit'] as num?)?.toInt() ?? 0;
      final previous = _previousCredit;
      _previousCredit = credit;

      if (previous != null &&
          credit < previous &&
          credit <= _lowCreditThreshold) {
        unawaited(_maybeShowPrompt(user.uid, credit));
      }
    });
  }

  Future<void> _maybeShowPrompt(String userId, int remainingCredit) async {
    // Kredi güncellemesi, rota geçişi sırasında gelebilir. Snackbar'ı yöneten
    // kök ScaffoldMessenger hazır olmadan günlük gösterim hakkını tüketme.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || scaffoldMessengerKey.currentState == null) return;

    final dayKey = _localDayKey(DateTime.now());
    final contextRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('context');

    final shouldShow = await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        final snapshot = await transaction.get(contextRef);
        if (snapshot.data()?['lastLowCreditSnackbarDay'] == dayKey) {
          return false;
        }

        transaction.set(
          contextRef,
          {
            'lastLowCreditSnackbarDay': dayKey,
            'lastLowCreditSnackbarAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return true;
      },
    );
    if (!shouldShow || !mounted) return;

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          backgroundColor: const Color(0xFF45258F),
          elevation: 10,
          content: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFFFFD27A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ücretsiz kredi fırsatı',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$remainingCredit kredin kaldı • 2 reklam = 5 kredi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'KAZAN',
            textColor: const Color(0xFFFFD27A),
            onPressed: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute<void>(
                  builder: (_) => const BuyCreditsScreen(),
                ),
              );
            },
          ),
        ),
      );
  }

  String _localDayKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  void dispose() {
    _creditSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
