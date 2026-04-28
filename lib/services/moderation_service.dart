import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soframda_ne_eksik/core/utils/content_moderation_utils.dart';

class ModerationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _accountRef => _db
      .collection('users')
      .doc(_uid)
      .collection('private')
      .doc('account');

  CollectionReference<Map<String, dynamic>> get _blocksRef => _db
      .collection('users')
      .doc(_uid)
      .collection('private')
      .doc('blocks')
      .collection('items');

  Stream<bool> watchTermsAccepted() {
    return _accountRef.snapshots().map((snapshot) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      return (data['termsVersion'] ?? '') == kCommunityTermsVersion;
    });
  }

  Future<bool> hasAcceptedTerms() async {
    final snapshot = await _accountRef.get();
    final data = snapshot.data() ?? const <String, dynamic>{};
    return (data['termsVersion'] ?? '') == kCommunityTermsVersion;
  }

  Future<void> acceptTerms() async {
    await _accountRef.set({
      'termsVersion': kCommunityTermsVersion,
      'termsAcceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Set<String>> watchBlockedUserIds() {
    return _accountRef.snapshots().map((snapshot) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      final ids = List<String>.from(data['blockedUserIds'] ?? const []);
      return ids.toSet();
    });
  }

  Future<Set<String>> getBlockedUserIds() async {
    final snapshot = await _accountRef.get();
    final data = snapshot.data() ?? const <String, dynamic>{};
    return List<String>.from(data['blockedUserIds'] ?? const []).toSet();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBlockedUsers() {
    return _blocksRef.orderBy('blockedAt', descending: true).snapshots();
  }

  Future<void> reportUser({
    required String targetUserId,
    required String reason,
    String details = '',
    Map<String, dynamic>? metadata,
  }) async {
    final callable = _functions.httpsCallable('reportContent');
    await callable.call({
      'contentType': 'user',
      'contentId': targetUserId,
      'targetUserId': targetUserId,
      'reason': reason,
      'details': details,
      'metadata': metadata ?? const <String, dynamic>{},
    });
  }

  Future<void> reportRequest({
    required String requestId,
    required String ownerId,
    required String reason,
    String details = '',
    Map<String, dynamic>? metadata,
  }) async {
    final callable = _functions.httpsCallable('reportContent');
    await callable.call({
      'contentType': 'request',
      'contentId': requestId,
      'targetUserId': ownerId,
      'reason': reason,
      'details': details,
      'metadata': metadata ?? const <String, dynamic>{},
    });
  }

  Future<void> blockUser({
    required String targetUserId,
    String targetName = '',
    String reason = '',
    Map<String, dynamic>? metadata,
  }) async {
    final callable = _functions.httpsCallable('blockUser');
    await callable.call({
      'targetUserId': targetUserId,
      'targetName': targetName,
      'reason': reason,
      'metadata': metadata ?? const <String, dynamic>{},
    });
  }

  Future<void> unblockUser({
    required String targetUserId,
  }) async {
    final callable = _functions.httpsCallable('unblockUser');
    await callable.call({
      'targetUserId': targetUserId,
    });
  }
}
