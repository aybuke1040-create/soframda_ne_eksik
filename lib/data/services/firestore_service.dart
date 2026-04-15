import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRequests() {
    return _db.collection("requests").snapshots();
  }

  Future<void> createRequest(String title) {
    return _db.collection("requests").add({
      "title": title,
      "status": "open",
      "createdAt": Timestamp.now(),
    });
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
}
