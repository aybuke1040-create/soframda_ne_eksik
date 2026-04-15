import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

class DeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getDeliveryRequests() {
    return _db
        .collection("requests")
        .where("requestType", isEqualTo: "delivery")
        .where("status", isEqualTo: "open")
        .snapshots();
  }

  Future createDeliveryRequest({
    required String title,
    required String description,
    required String pickupAddress,
    required String dropAddress,
    required double latitude,
    required double longitude,
    required String deliveryTime,
    required String imageUrl,
    required String ownerId,
    required String ownerName,
  }) async {
    await _db.collection("requests").add({
      "title": title,
      "description": description,
      "pickupAddress": pickupAddress,
      "dropAddress": dropAddress,
      "latitude": latitude,
      "longitude": longitude,
      "deliveryTime": deliveryTime,
      "imageUrl": imageUrl,
      "ownerId": ownerId,
      "ownerName": ownerName,
      "requestType": "delivery",
      "status": "open",
      "courierId": "",
      "completed": false,
      "createdAt": FieldValue.serverTimestamp(),
      "expiresAt": buildPublicExpiryTimestamp(
        requestType: "delivery",
      ),
    });
  }
}
