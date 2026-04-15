import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

class NearbyFoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔵 MEVCUT SİSTEM (HİÇ DOKUNMADIM)
  Future<List<DocumentSnapshot>> getNearbyFoods({
    required double latitude,
    required double longitude,
    double radiusInKm = 30,
  }) async {
    final center = GeoFirePoint(
      GeoPoint(latitude, longitude),
    );

    final collectionReference = _firestore.collection('requests');

    final docs = await GeoCollectionReference(collectionReference)
        .subscribeWithin(
          center: center,
          radiusInKm: radiusInKm,
          field: 'location',
          geopointFrom: (doc) {
            final data = doc['location'];
            return data['geopoint'] as GeoPoint;
          },
        )
        .first;

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return isRequestVisibleForPublic(data);
    }).toList();
  }

  /// 🟡 YENİ: Featured varsa onu getir, yoksa nearby
  Future<List<DocumentSnapshot>> getFeaturedOrNearbyFoods({
    required double latitude,
    required double longitude,
    double radiusInKm = 30,
  }) async {
    final now = Timestamp.now();

    try {
      // 1️⃣ Featured ilanları çek
      final featuredSnapshot = await _firestore
          .collection('requests')
          .where('isFeatured', isEqualTo: true)
          .where('featuredUntil', isGreaterThan: now)
          .limit(20)
          .get();

      if (featuredSnapshot.docs.isNotEmpty) {
        return featuredSnapshot.docs.where((doc) {
          final data = doc.data();
          return isRequestVisibleForPublic(data);
        }).toList();
      }
    } catch (e) {
      // Hata olursa sistemi bozma → fallback nearby
      print("Featured fetch error: $e");
    }

    // 2️⃣ Fallback → mevcut sistem (AYNEN)
    return await getNearbyFoods(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );
  }
}
