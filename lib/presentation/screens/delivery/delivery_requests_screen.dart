import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

import 'create_delivery_request_screen.dart';
import 'delivery_detail_screen.dart';

class DeliveryRequestsScreen extends StatefulWidget {
  const DeliveryRequestsScreen({super.key});

  @override
  State<DeliveryRequestsScreen> createState() => _DeliveryRequestsScreenState();
}

class _DeliveryRequestsScreenState extends State<DeliveryRequestsScreen> {
  static const List<Map<String, dynamic>> _deliveryIdeas = [
    {
      'title': 'Aynı Gün Çiçek Teslimi',
      'icon': Icons.local_florist_outlined,
      'accent': Color(0xFF6AA06A),
      'presetDescription': 'Çiçek buketi aynı gün içinde teslim edilecek.',
    },
    {
      'title': 'Davet İçin Yemek Taşıma',
      'icon': Icons.restaurant_outlined,
      'accent': Color(0xFFCE7C3F),
      'presetDescription':
          'Hazır yemekler ve tepsiler dikkatli şekilde taşınacak.',
    },
    {
      'title': 'Evden Etkinliğe Pasta Götürme',
      'icon': Icons.cake_outlined,
      'accent': Color(0xFFD56A8A),
      'presetDescription': 'Pasta ve tatlı ürünleri ezilmeden teslim edilmeli.',
    },
    {
      'title': 'Hediyelik Paket Dağıtımı',
      'icon': Icons.card_giftcard_outlined,
      'accent': Color(0xFF6A78D1),
      'presetDescription':
          'Birden fazla paketin aynı rota üzerinde dağıtımı isteniyor.',
    },
    {
      'title': 'Kurumsal Evrak Teslimi',
      'icon': Icons.description_outlined,
      'accent': Color(0xFF4D88B3),
      'presetDescription': 'Belgeler güvenli ve zamanında teslim edilmeli.',
    },
    {
      'title': 'Mevlüt İkramı Taşıma',
      'icon': Icons.volunteer_activism_outlined,
      'accent': Color(0xFFA0694D),
      'presetDescription':
          'Toplu ikramlar belirlenen saatte adrese ulaştırılmalı.',
    },
    {
      'title': 'Ofis İçine İkram Taşıma',
      'icon': Icons.business_center_outlined,
      'accent': Color(0xFF5C7A90),
      'presetDescription':
          'Toplantı ve etkinlikler için servis ürünleri taşınacak.',
    },
    {
      'title': 'Özel Gün Hediye Teslimi',
      'icon': Icons.favorite_border,
      'accent': Color(0xFFC45F6E),
      'presetDescription': 'Sürpriz teslimat dikkatli ve zamanında yapılsın.',
    },
    {
      'title': 'Pazar Alışverişi Taşıma',
      'icon': Icons.shopping_bag_outlined,
      'accent': Color(0xFF6A9461),
      'presetDescription': 'Market veya pazar alışverişi adrese bırakılacak.',
    },
    {
      'title': 'Toplu İkram Paketleme ve Taşıma',
      'icon': Icons.inventory_2_outlined,
      'accent': Color(0xFF9C7048),
      'presetDescription': 'Hazırlanan paketler adrese eksiksiz ulaştırılmalı.',
    },
  ];

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
      return 0.96;
    }
    return 0.9;
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
    _getLocation();
  }

  Future<void> _getLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) {
      return;
    }
    setState(() => userPosition = pos);
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
      appBar: AppBar(title: const Text('Ben Taşırım')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('İlan Ver'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDeliveryRequestScreen(),
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
                title: 'Hızlı Başlangıç',
                subtitle:
                    'Taşıma ihtiyacına uygun hazır fikirlerden birini seçerek ilana başla.',
              ),
              const SizedBox(height: 12),
              _buildIdeaBanner(context),
              const SizedBox(height: 24),
              _buildSectionTitle(
                title: 'Açık Taşıma İlanları',
                subtitle: 'Yakındaki taşıma, teslimat ve dağıtım ilanları.',
              ),
              const SizedBox(height: 12),
              _buildRequestGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF8FF), Color(0xFFDCEEFF)],
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
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Teslimat ve taşıma ilanı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C6E99),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Taşıma ilanını hızla oluştur.',
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
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _bannerLabel('Yemek teslimi'),
                _bannerDot(),
                _bannerLabel('Çiçek taşıma'),
                _bannerDot(),
                _bannerLabel('Pasta goturme'),
                _bannerDot(),
                _bannerLabel('Evrak teslimi'),
                _bannerDot(),
                _bannerLabel('Toplu dagitim'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerLabel(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C6E99),
        ),
      ),
    );
  }

  Widget _bannerDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: SizedBox(
          width: 5,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF6DA9D2),
              shape: BoxShape.circle,
            ),
          ),
        ),
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

  Widget _buildIdeaBanner(BuildContext context) {
    final ideas = [..._deliveryIdeas]..sort(
        (a, b) => (a['title'] as String)
            .toLowerCase()
            .compareTo((b['title'] as String).toLowerCase()),
      );

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ideas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final idea = ideas[index];
          return _DeliveryIdeaCard(
            title: idea['title'] as String,
            icon: idea['icon'] as IconData,
            accent: idea['accent'] as Color,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateDeliveryRequestScreen(
                    presetTitle: idea['title'] as String,
                    presetDescription: idea['presetDescription'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('requestType', isEqualTo: 'delivery')
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        final items = docs
            .map((doc) {
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
                ...data,
                'distance': km,
              };
            })
            .whereType<Map<String, dynamic>>()
            .toList();

        items.sort(
          (a, b) =>
              (a['distance'] as double).compareTo(b['distance'] as double),
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
              'Henüz açık taşıma ilanı yok. İlk ilanı sen oluşturabilirsin.',
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridColumnCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _gridAspectRatio(context),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _DeliveryRequestCard(
              title: (item['title'] ?? '').toString(),
              imageUrl: (item['imageUrl'] ?? '').toString(),
              pickupAddress: (item['pickupAddress'] ?? '').toString(),
              dropAddress: (item['dropAddress'] ?? '').toString(),
              distanceKm: (item['distance'] as double?) ?? 0,
              deliveryTime: (item['deliveryTime'] ?? '').toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryDetailScreen(
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

class _DeliveryIdeaCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _DeliveryIdeaCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.14),
                accent.withOpacity(0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryRequestCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String pickupAddress;
  final String dropAddress;
  final double distanceKm;
  final String deliveryTime;
  final VoidCallback onTap;

  const _DeliveryRequestCard({
    required this.title,
    required this.imageUrl,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distanceKm,
    required this.deliveryTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDDE8F1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFFE8F2FA),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                size: 36,
                                color: Color(0xFF4D88B3),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C6E99),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alış: $pickupAddress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Birak: $dropAddress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (deliveryTime.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        deliveryTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C6E99),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

