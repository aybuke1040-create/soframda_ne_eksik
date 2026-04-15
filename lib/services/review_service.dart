import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReview({
    required String requestId,
    required String reviewerId,
    required String targetUserId,
    required double rating,
    required String comment,
  }) async {
    final reviewRef = _db.collection("reviews").doc();

    await reviewRef.set({
      "requestId": requestId,
      "reviewerId": reviewerId,
      "targetUserId": targetUserId,
      "rating": rating,
      "comment": comment,
      "createdAt": FieldValue.serverTimestamp(),
    });

    /// USER RATING UPDATE

    final userRef = _db.collection("users").doc(targetUserId);

    await _db.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);

      final data = userSnap.data()!;

      final ratingCount = (data["ratingCount"] ?? 0) + 1;
      final ratingAverage = (data["ratingAverage"] ?? 0);

      final newAverage =
          ((ratingAverage * (ratingCount - 1)) + rating) / ratingCount;

      transaction.update(userRef, {
        "ratingCount": ratingCount,
        "ratingAverage": newAverage,
      });
    });
  }
}
