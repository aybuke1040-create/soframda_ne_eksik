```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

Future<void> migrateRequestsLocation() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore
        .collection('requests')
        .limit(500) // 🔥 güvenlik (çok büyük datayı engeller)
        .get();

    print("Toplam ${snapshot.docs.length} doküman bulundu");

    final batch = firestore.batch();
    int updatedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['location'] != null) continue;

      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat == null || lng == null) {
        print("SKIP: ${doc.id} → lat/lng yok");
        continue;
      }

      // 🔥 TYPE SAFE
      final latNum = (lat as num).toDouble();
      final lngNum = (lng as num).toDouble();

      final geo = GeoFirePoint(
        GeoPoint(latNum, lngNum),
      );

      batch.update(doc.reference, {
        'location': geo.data,
      });

      updatedCount++;
    }

    await batch.commit();

    print("Bitti ✅ Güncellenen: $updatedCount");

  } catch (e, stack) {
    print("MIGRATION ERROR: $e");
    print(stack);
  }
}
```
