import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

enum MonthlyShareRewardStatus {
  success,
  alreadyClaimed,
  unavailable,
}

enum FeatureRequestStatus {
  success,
  alreadyFeatured,
  insufficientCredit,
  failed,
}

class CreditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// 🔥 CREDIT DÜŞ (ATOMIC)
  Future<void> spendCredits({
    required String userId,
    required int amount,
    required String action,
  }) async {
    final callable = _functions.httpsCallable('useCredits');
    await callable.call({
      'amount': amount,
      'action': action,
    });
  }

  /// 🔥 CREDIT EKLE
  Future<void> addCredits(int amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);

      int current = 0;

      if (snap.data() != null && snap.data()!['credit'] != null) {
        current = (snap.data()!['credit'] as num).toInt();
      }

      tx.update(userRef, {
        'credit': current + amount,
      });

      final historyRef = userRef.collection('credit_history').doc();

      tx.set(historyRef, {
        'action': "add_credit",
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<bool> claimDailyLoginBonus() async {
    try {
      final callable = _functions.httpsCallable('claimDailyLoginBonus');
      final result = await callable.call();
      final data = Map<String, dynamic>.from(result.data as Map);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<MonthlyShareRewardStatus> claimMonthlyShareReward() async {
    try {
      final callable = _functions.httpsCallable('claimMonthlyShareReward');
      final result = await callable.call();
      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['success'] == true) {
        return MonthlyShareRewardStatus.success;
      }

      if (data['alreadyClaimed'] == true) {
        return MonthlyShareRewardStatus.alreadyClaimed;
      }

      return MonthlyShareRewardStatus.unavailable;
    } on FirebaseFunctionsException {
      return MonthlyShareRewardStatus.unavailable;
    } catch (_) {
      return MonthlyShareRewardStatus.unavailable;
    }
  }

  Future<FeatureRequestStatus> featureRequest(String requestId) async {
    try {
      final callable = _functions.httpsCallable('featureRequest');
      final result = await callable.call({
        'requestId': requestId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);

      if (data['success'] == true && data['alreadyFeatured'] == true) {
        return FeatureRequestStatus.alreadyFeatured;
      }

      if (data['success'] == true) {
        return FeatureRequestStatus.success;
      }

      return FeatureRequestStatus.failed;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('featureRequest FirebaseFunctionsException: ${e.code} ${e.message}');
      if (e.code == 'failed-precondition') {
        return FeatureRequestStatus.insufficientCredit;
      }
      return FeatureRequestStatus.failed;
    } catch (_) {
      return FeatureRequestStatus.failed;
    }
  }

  /// 🔥 SAFE ACTION
  Future<bool> performAction({
    String? userId,
    required int cost,
    required String actionName,
    required Future<void> Function() onSuccess,
  }) async {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await spendCredits(
        userId: uid,
        amount: cost,
        action: actionName,
      );

      await onSuccess();

      return true;
    } catch (e) {
      print("PERFORM ACTION ERROR: $e");
      return false;
    }
  }

  /// 🔥 eski kullanım
  Future<bool> useCredits(int amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      await spendCredits(
        userId: userId,
        amount: amount,
        action: "manual_use",
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🔥 kredi oku
  Future<int> getUserCredits() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;

    final doc = await _db.collection('users').doc(userId).get();

    if (!doc.exists) return 0;

    final data = doc.data();

    if (data == null || data['credit'] == null) return 0;

    return (data['credit'] as num).toInt();
  }
}
