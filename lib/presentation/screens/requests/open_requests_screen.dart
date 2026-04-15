import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/utils/distance_utils.dart';
import 'package:soframda_ne_eksik/core/utils/location_utils.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/request_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';

class OpenRequestsScreen extends StatefulWidget {
  const OpenRequestsScreen({super.key});

  @override
  State<OpenRequestsScreen> createState() => _OpenRequestsScreenState();
}

class _OpenRequestsScreenState extends State<OpenRequestsScreen> {
  double? userLat;
  double? userLng;
  bool isLoadingLocation = true;

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  bool _isLandscapePhone(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height && size.shortestSide < 600;
  }

  int _gridColumnCount(BuildContext context) {
    if (_isLandscapePhone(context)) {
      return 4;
    }
    if (_isTablet(context)) {
      return 3;
    }
    return 2;
  }

  double _gridAspectRatio(BuildContext context) {
    if (_isLandscapePhone(context)) {
      return 1;
    }
    if (_isTablet(context)) {
      return 0.94;
    }
    return 0.84;
  }

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  bool _looksLikePrivateContact(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final compact = trimmed.replaceAll(' ', '');
    final hasAtSign = compact.contains('@');
    final digitsOnly = compact.replaceAll(RegExp(r'\D'), '');
    return hasAtSign || digitsOnly.length >= 10;
  }

  Future<void> loadLocation() async {
    try {
      final pos = await getUserLocation();

      if (!mounted) {
        return;
      }

      setState(() {
        userLat = pos.latitude;
        userLng = pos.longitude;
        isLoadingLocation = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (isLoadingLocation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userLat == null || userLng == null) {
      return const Scaffold(
        body: Center(child: Text("Konum alınamadı.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ben Yaparım"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("requests")
                  .where("type", isEqualTo: "food_request")
                  .where("status", isEqualTo: "open")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("İlanlar yüklenirken bir hata oluştu."),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = <Map<String, dynamic>>[];

                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  if (!isRequestVisibleForPublic(data)) {
                    continue;
                  }

                  double? lat;
                  double? lng;
                  final locationData = data["location"];

                  if (locationData is Map &&
                      locationData["geopoint"] is GeoPoint) {
                    final geo = locationData["geopoint"] as GeoPoint;
                    lat = geo.latitude;
                    lng = geo.longitude;
                  } else {
                    lat = (data["latitude"] as num?)?.toDouble();
                    lng = (data["longitude"] as num?)?.toDouble();
                  }

                  if (lat == null || lng == null) {
                    continue;
                  }

                  final distance = calculateDistance(
                    userLat!,
                    userLng!,
                    lat,
                    lng,
                  );

                  if (distance > 50) {
                    continue;
                  }

                  items.add({
                    "id": doc.id,
                    "ownerId": data["ownerId"],
                    "title": data["title"] ?? "",
                    "description": data["description"] ?? "",
                    "quantity": data["quantity"] ?? "",
                    "imageUrl": data["imageUrl"] ?? "",
                    "distance": distance,
                    "ownerName": data["ownerName"] ?? data["userName"] ?? "",
                    "isFeatured": data["isFeatured"] == true,
                    "isMine": data["ownerId"] == currentUserId,
                  });
                }

                items.sort(
                  (a, b) =>
                      (a["distance"] as double).compareTo(b["distance"] as double),
                );

                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "Yakınında açık ilan yok.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridColumnCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: _gridAspectRatio(context),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("offers")
                          .where("requestId", isEqualTo: item["id"])
                          .snapshots(),
                      builder: (context, offerSnapshot) {
                        final offerCount = offerSnapshot.data?.docs.length ?? 0;
                        final ownerId = item["ownerId"] as String? ?? "";
                        final quantity = (item["quantity"] as String).trim();
                        final description =
                            (item["description"] as String).trim();
                        final fallbackOwnerName =
                            (item["ownerName"] as String).trim();

                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: ownerId.isEmpty
                              ? null
                              : FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(ownerId)
                                  .get(),
                          builder: (context, ownerSnapshot) {
                            final profileName = ownerSnapshot.data?.data()?["name"]
                                    as String? ??
                                "";
                            final ownerName = profileName.trim().isNotEmpty
                                ? profileName.trim()
                                : (_looksLikePrivateContact(fallbackOwnerName)
                                    ? ""
                                    : fallbackOwnerName);

                            String subtitle = "";
                            if (quantity.isNotEmpty) {
                              subtitle = quantity;
                            } else if (description.isNotEmpty) {
                              subtitle = description;
                            } else if (ownerName.isNotEmpty) {
                              subtitle = ownerName;
                            }

                            subtitle = subtitle.isEmpty
                                ? "$offerCount teklif"
                                : "$subtitle • $offerCount teklif";

                            return FoodRequestCard(
                              request: {
                                ...item,
                                "userName": ownerName,
                                "ownerName": ownerName,
                              },
                              showActions: false,
                              subtitle: subtitle,
                              trailingLabel: item["isMine"] == true
                                  ? "Senin ilan"
                                  : "Teklife açık",
                              trailingLabelColor: item["isMine"] == true
                                  ? Colors.green
                                  : const Color(0xFFE67E22),
                              fallbackIcon: Icons.room_service_outlined,
                              topRightBadge: item["isFeatured"] == true
                                  ? "Öne çıktı"
                                  : "$offerCount teklif",
                              topRightBadgeColor: item["isFeatured"] == true
                                  ? Colors.orange
                                  : const Color(0xFF2D7FF9),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RequestDetailScreen(
                                      requestId: item["id"] as String,
                                      ownerId: ownerId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

