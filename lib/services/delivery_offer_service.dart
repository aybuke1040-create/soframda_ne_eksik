import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryOfferService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future sendOffer({
    required String requestId,
    required String courierId,
    required String ownerId,
  }) async {
    await _db.collection("offers").add({
      "requestId": requestId,
      "courierId": courierId,
      "requestOwnerId": ownerId,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _db
        .collection("requests")
        .doc(requestId)
        .update({"status": "offered"});
  }
}
