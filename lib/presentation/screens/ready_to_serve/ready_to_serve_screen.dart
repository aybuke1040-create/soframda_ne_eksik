import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/create_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';

import 'ready_food_detail_screen.dart';

class ReadyToServeScreen extends StatefulWidget {
  const ReadyToServeScreen({super.key});

  @override
  State<ReadyToServeScreen> createState() => _ReadyToServeScreenState();
}

class _ReadyToServeScreenState extends State<ReadyToServeScreen> {
  Position? userPosition;
  final Distance distance = const Distance();

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
    return 0.86;
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
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) {
      return;
    }

    setState(() {
      userPosition = pos;
    });
  }

  Widget buildSkeletonCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final maxWidth = _contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazır Yemekler'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Hazır Yemek Ekle'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateRequestScreen(
                presetTitle: 'Hazır Yemek',
                isReady: true,
              ),
            ),
          );
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _buildSectionTitle(
                title: 'Yakindaki Hazır Yemekler',
                subtitle: 'Satışa hazır ürünleri mesafeye göre karşılaştır.',
              ),
              const SizedBox(height: 12),
              _buildReadyFoodGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1E1), Color(0xFFFFE0BF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Satışa hazır yemek ilanı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9A4D00),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hazır yemeğini sergile, alıcılar sana ulaşsın.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.74),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _HeroBannerLabel('Hazır börek'),
                _HeroBannerDot(),
                _HeroBannerLabel('Günlük tatlı'),
                _HeroBannerDot(),
                _HeroBannerLabel('Aynı gün teslim'),
                _HeroBannerDot(),
                _HeroBannerLabel('Porsiyonlu satış'),
                _HeroBannerDot(),
                _HeroBannerLabel('Toplu ikram'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildReadyFoodGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('isReady', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          final columns = _gridColumnCount(context);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: _gridAspectRatio(context),
            ),
            itemCount: 6,
            itemBuilder: (_, __) => buildSkeletonCard(),
          );
        }

        final docs = snapshot.data!.docs;

        final items = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          if (!isRequestVisibleForPublic(data)) {
            return null;
          }

          final km = distance.as(
            LengthUnit.Kilometer,
            LatLng(userPosition!.latitude, userPosition!.longitude),
            LatLng(
              (data['latitude'] ?? 0).toDouble(),
              (data['longitude'] ?? 0).toDouble(),
            ),
          );

          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'imageUrl': data['imageUrl'] ?? '',
            'price': data['price'],
            'portion': data['portion'],
            'distance': km,
            'isFeatured': data['isFeatured'] == true,
            'ownerId': data['ownerId'] ?? '',
            'ownerName': data['ownerName'] ?? data['userName'] ?? '',
          };
        }).whereType<Map<String, dynamic>>().where((item) {
          final itemDistance = item['distance'] as double? ?? 9999;
          return itemDistance <= 30;
        }).toList();

        items.sort(
          (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
        );

        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE7DDCF)),
            ),
            child: const Text(
              'Yakında hazır yemek ilanı yok. İlk hazır yemek ilanını sen açabilirsin.',
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridColumnCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _gridAspectRatio(context),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final portion = (item['portion'] ?? 0).toString();
            final price = item['price'];
            final subtitle = price == null
                ? '$portion porsiyon'
                : '₺$price • $portion porsiyon';

            return FoodRequestCard(
              request: item,
              showActions: false,
              subtitle: subtitle,
              trailingLabel: 'Hazır',
              trailingLabelColor: const Color(0xFF1F8A4C),
              fallbackIcon: Icons.restaurant_menu_outlined,
              topRightBadge: item['isFeatured'] == true
                  ? 'Öne çıktı'
                  : '${(item['distance'] as double).toStringAsFixed(1)} km',
              topRightBadgeColor: item['isFeatured'] == true
                  ? Colors.orange
                  : const Color(0xFF2D7FF9),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadyFoodDetailScreen(
                      requestId: item['id'] as String,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HeroBannerLabel extends StatelessWidget {
  final String text;

  const _HeroBannerLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9A4D00),
        ),
      ),
    );
  }
}

class _HeroBannerDot extends StatelessWidget {
  const _HeroBannerDot();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: SizedBox(
          width: 5,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFB97A42),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

