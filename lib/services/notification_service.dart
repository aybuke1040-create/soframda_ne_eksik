import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    required String type,
    String? requestId,
    String? ownerId,
  }) async {
    await _db.collection('notifications').add({
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'type': type,
      'requestId': requestId,
      'ownerId': ownerId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
