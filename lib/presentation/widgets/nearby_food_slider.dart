import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_food_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';

class NearbyFoodScreen extends StatefulWidget {
  const NearbyFoodScreen({super.key});

  @override
  State<NearbyFoodScreen> createState() => _NearbyFoodScreenState();
}

class _NearbyFoodScreenState extends State<NearbyFoodScreen> {
  Stream<List<DocumentSnapshot>>? _stream;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final center = GeoFirePoint(
      GeoPoint(position.latitude, position.longitude),
    );

    final collection = FirebaseFirestore.instance.collection("requests");

    final geoRef = GeoCollectionReference(collection);

    final stream = geoRef.subscribeWithin(
      center: center,
      radiusInKm: 5,
      field: "location",
      geopointFrom: (data) {
        return (data["location"]["geopoint"] as GeoPoint);
      },
    );

    setState(() {
      _stream = stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yakındaki Yemekler"),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Yakında ilan bulunamadı"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return FoodRequestCard(
                request: {
                  ...data,
                  "id": doc.id,
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadyFoodDetailScreen(
                        requestId: doc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
