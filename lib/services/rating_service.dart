import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitRating({
    required String userId,
    required double rating,
  }) async {
    final userRef = _db.collection("users").doc(userId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);

      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;

      final double currentAvg = (data["ratingAverage"] ?? 0).toDouble();
      final int count = data["ratingCount"] ?? 0;

      final newCount = count + 1;

      final newAvg = ((currentAvg * count) + rating) / newCount;

      tx.update(userRef, {
        "ratingAverage": newAvg,
        "ratingCount": newCount,
      });
    });
  }
}
