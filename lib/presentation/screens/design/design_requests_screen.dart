import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/create_design_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/design/design_detail_screen.dart';
import 'package:soframda_ne_eksik/presentation/widgets/food_request_card.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';

import '../../../core/utils/distance_utils.dart';
import '../../../core/utils/location_utils.dart';

class DesignRequestsScreen extends StatefulWidget {
  const DesignRequestsScreen({super.key});

  @override
  State<DesignRequestsScreen> createState() => _DesignRequestsScreenState();
}

class _DesignRequestsScreenState extends State<DesignRequestsScreen> {
  static const List<Map<String, dynamic>> _designIdeas = [
    {
      'title': 'Acilis Organizasyonu',
      'category': 'Kurumsal',
      'presetCategory': 'kurumsal',
      'icon': Icons.celebration_outlined,
      'accent': Color(0xFFAD5C1A),
      'description':
          'Mağaza, ofis veya marka açılışına uygun tasarım teklifi al.',
    },
    {
      'title': 'Baby Shower Konsepti',
      'category': 'Ozel Gun',
      'presetCategory': 'baby_shower',
      'icon': Icons.child_care_outlined,
      'accent': Color(0xFFDD7FA2),
      'description':
          'Masa düzeni, ikram alanı ve dekor fikirleri için ilan aç.',
    },
    {
      'title': 'Backdrop Tasarımı',
      'category': 'Tema Stil',
      'presetCategory': 'backdrop',
      'icon': Icons.photo_size_select_large_outlined,
      'accent': Color(0xFF5B6CFF),
      'description': 'Sahne arkası, karşılama panosu ve çekim alanı tasarlat.',
    },
    {
      'title': 'Bekarliga Veda',
      'category': 'Kutlama',
      'presetCategory': 'bekarliga_veda',
      'icon': Icons.nightlife_outlined,
      'accent': Color(0xFF7A4DA3),
      'description':
          'Eğlenceli, enerjik ve fotoğraflık bir kurgu için teklif topla.',
    },
    {
      'title': 'Butik Doğum Günü',
      'category': 'Kutlama',
      'presetCategory': 'dogum_gunu',
      'icon': Icons.cake_outlined,
      'accent': Color(0xFFE26D7D),
      'description': 'Evde veya mekanda butik kutlama kurulumu için ilan ver.',
    },
    {
      'title': 'Cinsiyet Partisi',
      'category': 'Ozel Gun',
      'presetCategory': 'gender_party',
      'icon': Icons.favorite_border,
      'accent': Color(0xFFCC7FE6),
      'description': 'Sürpriz açıklama köşesi ve masa dekoru için uzman bul.',
    },
    {
      'title': 'Diş Buğdayı',
      'category': 'Ozel Gun',
      'presetCategory': 'dis_bugdayi',
      'icon': Icons.child_friendly_outlined,
      'accent': Color(0xFF8D9EFF),
      'description': 'Bebek kutlaması için konsept, masa ve sunum desteği al.',
    },
    {
      'title': 'Düğün Karşılama Alanı',
      'category': 'Ozel Gun',
      'presetCategory': 'dugun',
      'icon': Icons.auto_awesome_outlined,
      'accent': Color(0xFFC69A4B),
      'description':
          'Karşılama panosu, çiçek ve oturma planı için tasarımcı ara.',
    },
    {
      'title': 'Happy Hour Alanı',
      'category': 'Kurumsal',
      'presetCategory': 'happy_hour',
      'icon': Icons.local_bar_outlined,
      'accent': Color(0xFFE49037),
      'description': 'Ofis veya mekan için sosyal etkinlik kurulumu tasarlat.',
    },
    {
      'title': 'Kahve Köşesi Tasarımı',
      'category': 'Kurumsal',
      'presetCategory': 'coffee_corner',
      'icon': Icons.coffee_outlined,
      'accent': Color(0xFF8B5E3C),
      'description': 'Etkinlikte şık ve düzenli bir servis köşesi oluştur.',
    },
    {
      'title': 'Kına Gecesi',
      'category': 'Ozel Gun',
      'presetCategory': 'kina',
      'icon': Icons.spa_outlined,
      'accent': Color(0xFFB6435A),
      'description': 'Kırmızı-altın tonlarda konsept kurulum için teklif al.',
    },
    {
      'title': 'Kurumsal Lansman',
      'category': 'Kurumsal',
      'presetCategory': 'kurumsal',
      'icon': Icons.campaign_outlined,
      'accent': Color(0xFF3A6EA5),
      'description': 'Marka sunumu ve fotoğraf alanları için düzenleme yaptır.',
    },
    {
      'title': 'Mezuniyet Kutlaması',
      'category': 'Kutlama',
      'presetCategory': 'mezuniyet',
      'icon': Icons.school_outlined,
      'accent': Color(0xFF355C7D),
      'description':
          'Gençlik enerjisine uygun sahne ve masa tasarımı talep et.',
    },
    {
      'title': 'Nişan Konsepti',
      'category': 'Ozel Gun',
      'presetCategory': 'nisan',
      'icon': Icons.favorite_outline,
      'accent': Color(0xFFD95A6F),
      'description':
          'Aile tanışması ve nişan masası için zarif bir kurgu iste.',
    },
    {
      'title': 'Parti Masa Düzeni',
      'category': 'Tema Stil',
      'presetCategory': 'masa_duzeni',
      'icon': Icons.table_restaurant_outlined,
      'accent': Color(0xFF5F7A61),
      'description':
          'Sunum, servis ve dekoru bir araya getiren masa kurgusu kur.',
    },
    {
      'title': 'Piknik Konsepti',
      'category': 'Kutlama',
      'presetCategory': 'piknik',
      'icon': Icons.park_outlined,
      'accent': Color(0xFF4D9B67),
      'description':
          'Açılır masa, minder ve fotoğraf alanıyla keyifli bir konsept iste.',
    },
    {
      'title': 'Söz İsteme Düzeni',
      'category': 'Ozel Gun',
      'presetCategory': 'soz',
      'icon': Icons.volunteer_activism_outlined,
      'accent': Color(0xFF8C5A72),
      'description':
          'Evde yapılan özel gün için şık ve sade bir düzen oluştur.',
    },
    {
      'title': 'Stand Tasarımı',
      'category': 'Kurumsal',
      'presetCategory': 'stand',
      'icon': Icons.storefront_outlined,
      'accent': Color(0xFF2C7DA0),
      'description':
          'Fuarda veya etkinlikte dikkat çeken bir sunum alanı tasarlat.',
    },
    {
      'title': 'Temalı Doğum Günü',
      'category': 'Tema Stil',
      'presetCategory': 'dogum_gunu',
      'icon': Icons.stars_outlined,
      'accent': Color(0xFF9B5DE5),
      'description':
          'Belirli renk, karakter ya da stil üzerine konsept hazırlat.',
    },
    {
      'title': 'Yıldönümü Kutlaması',
      'category': 'Kutlama',
      'presetCategory': 'yildonumu',
      'icon': Icons.favorite_border_outlined,
      'accent': Color(0xFFC25B5B),
      'description':
          'Romantik masa ve dekor düzeni için profesyonel destek al.',
    },
  ];

  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    final pos = await getUserLocation();

    if (!mounted) {
      return;
    }

    setState(() {
      userLat = pos.latitude;
      userLng = pos.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ben Dizayn Ederim'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDesignRequestScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('İlan Ver'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _buildSectionTitle(
                  title: 'Hızlı Başlangıç',
                  subtitle:
                      'Hazır konseptlerden birini seçip ilana hızla başla.',
                ),
                const SizedBox(height: 12),
                _buildIdeaBanner(context),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  title: 'Açık Tasarım İlanları',
                  subtitle:
                      'Tasarlanmayı bekleyen kutlama ve organizasyon ilanları.',
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('requests')
                      .where('requestType', isEqualTo: 'design')
                      .where('status', isEqualTo: 'open')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child:
                            Text('Organizasyon ilanları şu anda yüklenemedi.'),
                      );
                    }

                    final docs = [...(snapshot.data?.docs ?? [])];
                    docs.removeWhere((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return !isRequestVisibleForPublic(data);
                    });

                    docs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aDistance = calculateDistance(
                        userLat ?? 0,
                        userLng ?? 0,
                        (aData['latitude'] ?? 0).toDouble(),
                        (aData['longitude'] ?? 0).toDouble(),
                      );
                      final bDistance = calculateDistance(
                        userLat ?? 0,
                        userLng ?? 0,
                        (bData['latitude'] ?? 0).toDouble(),
                        (bData['longitude'] ?? 0).toDouble(),
                      );
                      return aDistance.compareTo(bDistance);
                    });

                    if (docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE7DDCF)),
                        ),
                        child: const Text(
                          'Henüz açık dizayn talebi yok. İlk organizasyon ilanını sen açabilirsin.',
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final requestId = doc.id;
                        final ownerId = data['ownerId'] as String? ?? '';
                        final category = data['category'] as String? ?? '';
                        final distance = calculateDistance(
                          userLat ?? 0,
                          userLng ?? 0,
                          (data['latitude'] ?? 0).toDouble(),
                          (data['longitude'] ?? 0).toDouble(),
                        );

                        return Stack(
                          children: [
                            FoodRequestCard(
                              request: {
                                'id': requestId,
                                'title': data['title'] ?? '',
                                'imageUrl': data['imageUrl'],
                                'ownerId': ownerId,
                                'userName': data['ownerName'] ?? '',
                                'distance': distance,
                              },
                              showActions: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DesignDetailScreen(
                                      requestId: requestId,
                                    ),
                                  ),
                                );
                              },
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
                                  color: categoryColor(category),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  categoryLabel(category),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            if (ownerId == currentUserId)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.68),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Senin ilanın',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3EA), Color(0xFFFFD7C7)],
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
              'Organizasyon ve dekor ilanı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9A4D00),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Konseptini seç, ilanını aç.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Text(
                    'Dogum gunu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                _bannerDot(),
                Center(
                  child: Text(
                    'Nisan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                _bannerDot(),
                Center(
                  child: Text(
                    'Baby shower',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                _bannerDot(),
                Center(
                  child: Text(
                    'Dugun',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                _bannerDot(),
                Center(
                  child: Text(
                    'Kurumsal etkinlik',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                _bannerDot(),
                Center(
                  child: Text(
                    'Backdrop tasarımı',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFB97A42),
            shape: BoxShape.circle,
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
    final ideas = _ideasForBanner();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ideas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final idea = ideas[index];
          return _DesignIdeaCard(
            title: idea['title'] as String,
            icon: idea['icon'] as IconData,
            accent: idea['accent'] as Color,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateDesignRequestScreen(
                    presetTitle: idea['title'] as String,
                    presetCategory: idea['presetCategory'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _ideasForBanner() {
    return [..._designIdeas]..sort(
        (a, b) => (a['title'] as String)
            .toLowerCase()
            .compareTo((b['title'] as String).toLowerCase()),
      );
  }
}

String categoryLabel(String key) {
  switch (key) {
    case 'baby_shower':
      return 'Baby Shower';
    case 'bekarliga_veda':
      return 'Bekarliga Veda';
    case 'coffee_corner':
      return 'Kahve Köşesi';
    case 'dis_bugdayi':
      return 'Dis Bugdayi';
    case 'dogum_gunu':
      return 'Dogum Gunu';
    case 'dugun':
      return 'Dugun';
    case 'gender_party':
      return 'Cinsiyet Partisi';
    case 'happy_hour':
      return 'Happy Hour';
    case 'kina':
      return 'Kina';
    case 'kurumsal':
      return 'Kurumsal';
    case 'masa_duzeni':
      return 'Masa Duzeni';
    case 'mezuniyet':
      return 'Mezuniyet';
    case 'nisan':
      return 'Nisan';
    case 'piknik':
      return 'Piknik';
    case 'soz':
      return 'Söz İsteme';
    case 'stand':
      return 'Stand';
    case 'backdrop':
      return 'Backdrop';
    case 'yildonumu':
      return 'Yıldönümü';
    default:
      return 'Organizasyon';
  }
}

Color categoryColor(String key) {
  switch (key) {
    case 'baby_shower':
      return const Color(0xFFDD7FA2);
    case 'bekarliga_veda':
      return const Color(0xFF7A4DA3);
    case 'coffee_corner':
      return const Color(0xFF8B5E3C);
    case 'dis_bugdayi':
      return const Color(0xFF8D9EFF);
    case 'dogum_gunu':
      return const Color(0xFFE26D7D);
    case 'dugun':
      return const Color(0xFFC69A4B);
    case 'gender_party':
      return const Color(0xFFCC7FE6);
    case 'happy_hour':
      return const Color(0xFFE49037);
    case 'kina':
      return const Color(0xFFB6435A);
    case 'kurumsal':
      return const Color(0xFF3A6EA5);
    case 'masa_duzeni':
      return const Color(0xFF5F7A61);
    case 'mezuniyet':
      return const Color(0xFF355C7D);
    case 'nisan':
      return const Color(0xFFD95A6F);
    case 'piknik':
      return const Color(0xFF4D9B67);
    case 'soz':
      return const Color(0xFF8C5A72);
    case 'stand':
      return const Color(0xFF2C7DA0);
    case 'backdrop':
      return const Color(0xFF5B6CFF);
    case 'yildonumu':
      return const Color(0xFFC25B5B);
    default:
      return Colors.grey;
  }
}

class _DesignIdeaCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _DesignIdeaCard({
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
                accent.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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


