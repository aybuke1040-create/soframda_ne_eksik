import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> requests() {
    return _db.collection("requests").snapshots();
  }

  Future<void> createRequest(String title) {
    return _db.collection("requests").add({
      "title": title,
      "status": "open",
      "createdAt": Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> offers(String requestId) {
    return _db
        .collection("requests")
        .doc(requestId)
        .collection("offers")
        .snapshots();
  }

  Future<void> sendOffer(String requestId, int price) {
    return _db.collection("requests").doc(requestId).collection("offers").add({
      "price": price,
      "accepted": false,
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> acceptOffer(String requestId, String offerId) async {
    final ref = _db.collection("requests").doc(requestId);
    await ref.update({"status": "accepted"});
    await ref.collection("offers").doc(offerId).update({"accepted": true});
  }

  Future<void> submitReview({
    required String targetUserId,
    required String requestId,
    required int rating,
    required String comment,
  }) async {
    final reviewerId = FirebaseAuth.instance.currentUser!.uid;

    final reviewRef = FirebaseFirestore.instance.collection("reviews").doc();

    await reviewRef.set({
      "reviewerId": reviewerId,
      "targetUserId": targetUserId,
      "rating": rating,
      "comment": comment,
      "requestId": requestId,
      "createdAt": Timestamp.now(),
    });

    final userRef =
        FirebaseFirestore.instance.collection("users").doc(targetUserId);

    final userDoc = await userRef.get();

    final data = userDoc.data() ?? {};

    final currentAverage = (data["ratingAverage"] ?? 0).toDouble();
    final count = (data["ratingCount"] ?? 0);

    final newCount = count + 1;

    final newAverage = ((currentAverage * count) + rating) / newCount;

    await userRef.update({
      "ratingAverage": newAverage,
      "ratingCount": newCount,
    });
  }

  /// READY TO SERVE FOODS
  Stream<QuerySnapshot> readyFoods() {
    return FirebaseFirestore.instance
        .collection("requests")
        .where("isReady", isEqualTo: true)
        .snapshots();
  }
}
