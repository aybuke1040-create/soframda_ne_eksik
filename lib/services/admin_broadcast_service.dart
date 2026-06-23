import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminBroadcast {
  const AdminBroadcast({
    required this.id,
    required this.title,
    required this.body,
    this.actionLabel,
    this.actionUrl,
    this.androidActionUrl,
    this.iosActionUrl,
  });

  final String id;
  final String title;
  final String body;
  final String? actionLabel;
  final String? actionUrl;
  final String? androidActionUrl;
  final String? iosActionUrl;

  String? get platformActionUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS && iosActionUrl != null) {
      return iosActionUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android &&
        androidActionUrl != null) {
      return androidActionUrl;
    }

    return actionUrl;
  }
}

class AdminBroadcastService {
  AdminBroadcastService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _privateContextRef(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('context');
  }

  Future<AdminBroadcast?> getPendingBroadcast() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final contextSnapshot = await _privateContextRef(user.uid).get();
    final contextData = contextSnapshot.data() ?? const <String, dynamic>{};
    final dismissedIds = List<String>.from(
        contextData['dismissedAdminBroadcastIds'] ?? const []);

    final snapshot = await _db
        .collection('admin_broadcasts')
        .where('active', isEqualTo: true)
        .where('showOnOpen', isEqualTo: true)
        .limit(20)
        .get();

    final now = DateTime.now();
    final docs = snapshot.docs.where((doc) {
      if (dismissedIds.contains(doc.id)) {
        return false;
      }

      final data = doc.data();
      final expiresAt = data['expiresAt'];
      if (expiresAt is Timestamp && expiresAt.toDate().isBefore(now)) {
        return false;
      }

      final title = (data['title'] ?? '').toString().trim();
      final body = (data['body'] ?? '').toString().trim();
      return title.isNotEmpty && body.isNotEmpty;
    }).toList()
      ..sort((a, b) {
        final aCreated = a.data()['createdAt'];
        final bCreated = b.data()['createdAt'];
        final aDate = aCreated is Timestamp
            ? aCreated.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = bCreated is Timestamp
            ? bCreated.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    if (docs.isEmpty) {
      return null;
    }

    final doc = docs.first;
    final data = doc.data();
    return AdminBroadcast(
      id: doc.id,
      title: data['title'].toString().trim(),
      body: data['body'].toString().trim(),
      actionLabel: (data['actionLabel'] ?? '').toString().trim().isEmpty
          ? null
          : data['actionLabel'].toString().trim(),
      actionUrl: (data['actionUrl'] ?? '').toString().trim().isEmpty
          ? null
          : data['actionUrl'].toString().trim(),
      androidActionUrl:
          (data['androidActionUrl'] ?? '').toString().trim().isEmpty
              ? null
              : data['androidActionUrl'].toString().trim(),
      iosActionUrl: (data['iosActionUrl'] ?? '').toString().trim().isEmpty
          ? null
          : data['iosActionUrl'].toString().trim(),
    );
  }

  Future<void> dismiss(String broadcastId) async {
    final user = _auth.currentUser;
    if (user == null || broadcastId.trim().isEmpty) {
      return;
    }

    await _privateContextRef(user.uid).set({
      'dismissedAdminBroadcastIds': FieldValue.arrayUnion([broadcastId]),
      'lastAdminBroadcastDismissedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
