import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/core/utils/distance_utils.dart';
import 'package:soframda_ne_eksik/core/utils/location_utils.dart';
import 'package:soframda_ne_eksik/core/utils/ui_helpers.dart';
import 'package:soframda_ne_eksik/models/request_model.dart';
import 'package:soframda_ne_eksik/presentation/screens/chat/chat_list_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/delivery/delivery_requests_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/design_requests_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/notifications/notifications_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_food_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_to_serve_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/recipes/recipes_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/my_requests_screen.dart'
    as req;
import 'package:soframda_ne_eksik/presentation/screens/requests/open_requests_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/credit_badge.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/nearby_food_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NearbyFoodService _nearbyFoodService;

  double? userLat;
  double? userLng;
  List<DocumentSnapshot> foods = [];
  bool isLoading = true;
  bool isFeaturedMode = false;

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  bool _isLandscapePhone(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height && size.shortestSide < 600;
  }

  int _serviceColumnCount(BuildContext context) {
    if (_isLandscapePhone(context)) {
      return 4;
    }
    if (_isTablet(context)) {
      return 3;
    }
    return 2;
  }

  int _listingColumnCount(BuildContext context) {
    if (_isLandscapePhone(context)) {
      return 4;
    }
    if (_isTablet(context)) {
      return 3;
    }
    return 2;
  }

  double _contentMaxWidth(BuildContext context) {
    if (_isTablet(context)) {
      return 1100;
    }
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _nearbyFoodService = NearbyFoodService();
    _loadLocation();
    _claimDailyBonusSecure();
  }

  Future<void> _claimDailyBonusSecure() async {
    final granted = await CreditService().claimDailyLoginBonus();

    if (granted) {
      if (mounted) {
        showCreditAnimation(context, "+5");
      }

      HapticFeedback.lightImpact();
      HapticFeedback.mediumImpact();
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _loadLocation() async {
    final pos = await getUserLocation();

    if (!mounted) {
      return;
    }

    setState(() {
      userLat = pos.latitude;
      userLng = pos.longitude;
    });

    loadFoods();
  }

  Future<void> loadFoods() async {
    if (userLat == null || userLng == null) {
      return;
    }

    setState(() => isLoading = true);

    final result = await _nearbyFoodService.getFeaturedOrNearbyFoods(
      latitude: userLat!,
      longitude: userLng!,
    );

    var featured = false;
    if (result.isNotEmpty) {
      final data = result.first.data() as Map<String, dynamic>;
      featured = data['isFeatured'] == true;
    }

    setState(() {
      foods = result;
      isLoading = false;
      isFeaturedMode = featured;
    });
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 243, 152, 66),
            Color.fromARGB(255, 255, 119, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('Merhaba', 'Hello'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
              Row(
                children: [
                  const CreditBadge(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.t(
                'Mahallenin Ortak Mutfağı', 'The Neighborhood Shared Kitchen'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('Bugün ne istiyorsun?', 'What would you like today?'),
            style: const TextStyle(
              color: Color.fromARGB(179, 104, 1, 1),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServiceGrid() {
    final columns = _serviceColumnCount(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
        children: [
          ServiceCard(
            title:
                context.t('Masamda Ne Eksik', 'What Is Missing on the Table'),
            icon: Icons.help_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => req.MyRequestsScreen(),
                ),
              );
            },
          ),
          ServiceCard(
            title: context.t('Ben Yaparım', 'I Can Make It'),
            icon: Icons.kitchen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OpenRequestsScreen(),
                ),
              );
            },
          ),
          ServiceCard(
            title: context.t('Hazır Yemekler', 'Ready Meals'),
            icon: Icons.restaurant,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReadyToServeScreen(),
                ),
              );
            },
          ),
          ServiceCard(
            title: context.t('Benim Favori Tarifim', 'My Recipe'),
            icon: Icons.menu_book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipesScreen(),
                ),
              );
            },
          ),
          ServiceCard(
            title: context.t('Ben Taşırım', 'I Can Deliver'),
            icon: Icons.local_shipping,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeliveryRequestsScreen(),
                ),
              );
            },
          ),
          ServiceCard(
            title: context.t('Ben Dizayn Ederim', 'I Can Design'),
            icon: Icons.design_services,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DesignRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildNearbyFoods() {
    if (userLat == null || userLng == null || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final visibleFoods = foods.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final type = (data['type'] ?? '').toString();
      final ownerId = (data['ownerId'] ?? '').toString();
      return type == 'ready_food' &&
          (currentUserId == null || ownerId != currentUserId);
    }).toList();

    if (visibleFoods.isEmpty) {
      return Center(
        child: Text(
            context.t('Yakında yemek bulunamadı', 'No nearby meals found')),
      );
    }

    final sortedFoods = visibleFoods.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final request = RequestModel.fromFirestore(data, doc.id);
      final geo = data['location']['geopoint'];

      final distance = calculateDistance(
        userLat!,
        userLng!,
        geo.latitude,
        geo.longitude,
      );

      return {
        "request": request,
        "distance": distance,
        "isFeatured": data['isFeatured'] == true,
      };
    }).toList();

    if (!isFeaturedMode) {
      sortedFoods.sort(
        (a, b) => (a["distance"] as double).compareTo(b["distance"] as double),
      );
    }

    final columns = _listingColumnCount(context);
    final double childAspectRatio =
        _isLandscapePhone(context) ? 1.0 : (_isTablet(context) ? 0.94 : 0.86);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: sortedFoods.length,
      itemBuilder: (context, index) {
        final item = sortedFoods[index];
        final request = item["request"] as RequestModel;
        final distance = item["distance"] as double;
        final isFeatured = item["isFeatured"] as bool;

        return Stack(
          children: [
            FoodRequestCard(
              request: {
                "id": request.id,
                "title": request.title,
                "imageUrl": request.imageUrl,
                "ownerId": request.ownerId,
                "userName": request.ownerName,
                "price": request.price,
                "portion": request.portion,
                "distance": distance,
                "type": "ready_food",
                "isReady": true,
              },
              showActions: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadyFoodDetailScreen(
                      requestId: request.id,
                    ),
                  ),
                );
              },
            ),
            if (isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.t('ÖNE ÇIKAN', 'FEATURED'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        isFeaturedMode
            ? context.t('Öne Çıkanlar', 'Featured')
            : context.t('Yakındaki Yemekler', 'Nearby Meals'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = _contentMaxWidth(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                buildServiceGrid(),
                buildSectionTitle(),
                const SizedBox(height: 10),
                buildNearbyFoods(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
