import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_food_detail_screen.dart';
import 'create_request_screen.dart';

class AllRequestsScreen extends StatefulWidget {
  const AllRequestsScreen({super.key});

  @override
  State<AllRequestsScreen> createState() => _AllRequestsScreenState();
}

class _AllRequestsScreenState extends State<AllRequestsScreen> {
  Position? userPosition;
  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() => userPosition = pos);
  }

  @override
  Widget build(BuildContext context) {
    if (userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("🍳 Ben Yaparım")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("İlan Ekle"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateRequestScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .where("requestType", isEqualTo: "food") // 🔥 sadece yemek
            .where("status", isEqualTo: "open")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Henüz ilan yok"));
          }

          /// 🔥 MAP + MESAFE
          final items = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (!isRequestVisibleForPublic(data)) {
              return null;
            }

            final lat = data["latitude"] ?? 0;
            final lng = data["longitude"] ?? 0;

            final km = distance.as(
              LengthUnit.Kilometer,
              LatLng(userPosition!.latitude, userPosition!.longitude),
              LatLng(lat, lng),
            );

            return {
              "id": doc.id,
              ...data,
              "distance": km,
            };
          }).whereType<Map<String, dynamic>>().toList();

          /// 🔥 SIRALA
          items.sort((a, b) =>
              (a["distance"] as double).compareTo(b["distance"] as double));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return FoodRequestCard(
                request: item,
                showActions: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadyFoodDetailScreen(
                        requestId: item["id"],
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
