import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

Future<void> migrateRequestsLocation() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore.collection('requests').limit(500).get();

    // ignore: avoid_print
    print('Toplam ${snapshot.docs.length} dokuman bulundu');

    final batch = firestore.batch();
    var updatedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['location'] != null) {
        continue;
      }

      final lat = data['latitude'];
      final lng = data['longitude'];

      if (lat == null || lng == null) {
        // ignore: avoid_print
        print('SKIP: ${doc.id} -> lat/lng yok');
        continue;
      }

      final latNum = (lat as num).toDouble();
      final lngNum = (lng as num).toDouble();
      final geo = GeoFirePoint(GeoPoint(latNum, lngNum));

      batch.update(doc.reference, {
        'location': geo.data,
      });

      updatedCount++;
    }

    await batch.commit();

    // ignore: avoid_print
    print('Bitti. Guncellenen: $updatedCount');
  } catch (error, stackTrace) {
    // ignore: avoid_print
    print('MIGRATION ERROR: $error');
    // ignore: avoid_print
    print(stackTrace);
  }
}
