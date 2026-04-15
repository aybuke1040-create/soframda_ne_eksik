import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<void> ensureUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final uid = user.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);
    final snapshot = await userDoc.get();
    final existingData = snapshot.data();
    final existingName = (existingData?["name"] as String? ?? "").trim();
    final existingPhotoUrl = (existingData?["photoUrl"] as String? ?? "").trim();

    final data = {
      "name": existingName.isNotEmpty ? existingName : "Kullanici",
      "photoUrl": existingPhotoUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      await userDoc.set({
        ...data,
        "ratingAverage": 0,
        "ratingCount": 0,
        "recipesCount": 0,
        "completedOrders": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update(data);
    }

    await userDoc.collection("private").doc("account").set({
      "phoneNumber": user.phoneNumber ?? "",
      "email": user.email ?? "",
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await userDoc.set({
      "phoneNumber": FieldValue.delete(),
      "email": FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, Map<String, dynamic>>> getUsersByIds(
    List<String> userIds,
  ) async {
    final db = FirebaseFirestore.instance;

    if (userIds.isEmpty) return {};

    final chunks = <List<String>>[];

    for (var i = 0; i < userIds.length; i += 10) {
      chunks.add(
        userIds.sublist(
          i,
          i + 10 > userIds.length ? userIds.length : i + 10,
        ),
      );
    }

    final result = <String, Map<String, dynamic>>{};

    for (final chunk in chunks) {
      final query = await db
          .collection("users")
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in query.docs) {
        result[doc.id] = doc.data();
      }
    }

    return result;
  }
}
