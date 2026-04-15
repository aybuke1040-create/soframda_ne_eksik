import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

class RequestService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createRequest({
    required String title,
    required String description,
    required String ownerId,
    required double latitude,
    required double longitude,
    required double price,
    required int portion,
    required String imageUrl,
  }) async {
    final geo = GeoFirePoint(GeoPoint(latitude, longitude));

    await _firestore.collection('requests').add({
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'price': price,
      'portion': portion,
      'imageUrl': imageUrl,
      'location': geo.data,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': buildPublicExpiryTimestamp(
        requestType: 'food_request',
      ),
    });
  }
}
