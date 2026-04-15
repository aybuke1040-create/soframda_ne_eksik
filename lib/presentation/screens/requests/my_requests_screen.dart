import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/create_request_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/request_detail_screen.dart';

const String _ideasBasePath = 'assets/images/request_ideas';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  _IdeaCategory? _selectedCategory;

  late final List<_IdeaCategory> _categories = [
    _IdeaCategory(
      key: 'sicaklar',
      label: 'Ara Sıcaklar',
      image: '$_ideasBasePath/arasicak.jpg',
      options: const [
        _IdeaOption('Arnavut Ciğeri', 'Arnavut Ciğeri', 'arnavut_cigeri.jpg'),
        _IdeaOption('Çöp Şiş', 'Çöp Şiş', 'cop_sis.jpg'),
        _IdeaOption('Fırında Mücver', 'Fırın Mücver', 'firinda_mucver.jpg'),
        _IdeaOption('İçli Köfte', 'İçli Köfte', 'icli_kofte.jpg'),
        _IdeaOption('Izgara Köfte', 'Izgara Köfte', 'izgara_kofte.jpg'),
        _IdeaOption('Kaşarlı Mantar Dolması', 'Mantar Dolması', 'kasarli_mantar_dolmasi.jpg'),
        _IdeaOption('Kalamar Tava', 'Kalamar Tava', 'kalamar_tava.jpg'),
        _IdeaOption('Karides Güveç', 'Karides Güveç', 'karides_guvec.jpg'),
        _IdeaOption('Karides & Kalamar Karışık Tava', 'Karides Tava', 'karides_kalamar_tava.jpg'),
        _IdeaOption('Kızartma Tabağı', 'Kızartma Tabağı', 'kizartma_tabagi.jpg'),
        _IdeaOption('Mantarlı Çıtır Börek', 'Çıtır Börek', 'mantarli_citir_borek.jpg'),
        _IdeaOption('Nohutlu Köfte', 'Nohut Köfte', 'nohutlu_kofte.jpg'),
        _IdeaOption('Paçanga Böreği', 'Paçanga', 'pacanga_boregi.jpg'),
        _IdeaOption('Peynir Eritme / Hellim Izgara', 'Hellim Izgara', 'hellim_izgara.jpg'),
        _IdeaOption('Peynirli Fırın Patlıcan', 'Fırın Patlıcan', 'peynirli_firin_patlican.jpg'),
        _IdeaOption('Sıcak Humus', 'Sıcak Humus', 'sicak_humus.jpg'),
        _IdeaOption('Sıcak Ot Kavurma', 'Ot Kavurma', 'sicak_ot_kavurma.jpg'),
        _IdeaOption('Tavuk Şiş', 'Tavuk Şiş', 'tavuk_sis.jpg'),
        _IdeaOption('Yaprak Ciğer', 'Yaprak Ciğer', 'yaprak_ciger.jpg'),
        _IdeaOption('Yoğurtlu Mantı', 'Yoğurtlu Mantı', 'yogurtlu_manti.jpg'),
      ],
    ),
    _IdeaCategory(
      key: 'soguk_meze',
      label: 'Soğuk Mezeler',
      image: '$_ideasBasePath/soguk_mezeler.jpg',
      options: const [
        _IdeaOption('Acılı Ezme', 'Acılı Ezme', 'acili_ezme.jpg'),
        _IdeaOption('Atom', 'Atom', 'atom.jpg'),
        _IdeaOption('Babagannuş', 'Babagannuş', 'babagannus.jpg'),
        _IdeaOption('Cacık', 'Cacık', 'cacik.jpg'),
        _IdeaOption('Cevizli Kabak Tarator', 'Kabak Tarator', 'cevizli_kabak_tarator.jpg'),
        _IdeaOption('Çerkez Tavuğu', 'Çerkez Tavuğu', 'cerkez_tavugu.jpg'),
        _IdeaOption('Deniz Börülcesi', 'Deniz Börülcesi', 'deniz_borulcesi.jpg'),
        _IdeaOption('Haydari', 'Haydari', 'haydari.jpg'),
        _IdeaOption('Humus', 'Humus', 'humus.jpg'),
        _IdeaOption('Kalamar Salatası', 'Kalamar Salata', 'kalamar_salatasi.jpg'),
        _IdeaOption('Közlenmiş Biber Salatası', 'Biber Salatası', 'kozlenmis_biber_salatasi.jpg'),
        _IdeaOption('Mercimek Köftesi', 'Mercimek Köfte', 'mercimek_koftesi.jpg'),
        _IdeaOption('Muhammara', 'Muhammara', 'muhammara.jpg'),
        _IdeaOption('Nar Ekşili Piyaz', 'Nar Ekşili Piyaz', 'nar_eksili_piyaz.jpg'),
        _IdeaOption('Patlıcan Salatası', 'Patlıcan Salata', 'patlican_salatasi.jpg'),
        _IdeaOption('Rus Salatası', 'Rus Salatası', 'rus_salatasi.jpg'),
        _IdeaOption('Semizotu Salatası', 'Semizotu Salata', 'semizotu_salatasi.jpg'),
        _IdeaOption('Taratorlu Havuç', 'Taratorlu Havuç', 'taratorlu_havuc.jpg'),
        _IdeaOption('Yoğurtlu Pancar', 'Yoğurtlu Pancar', 'yogurtlu_pancar.jpg'),
        _IdeaOption('Zeytinyağlı Yaprak Sarma', 'Yaprak Sarma', 'zeytinyagli_yaprak_sarma.jpg'),
      ],
    ),
    _IdeaCategory(
      key: 'kutlama',
      label: 'Kutlama İkramları',
      image: '$_ideasBasePath/kokteylsunum.jpg',
      options: const [
        _IdeaOption('Çikolatalı Çilekler', 'Çilekler', 'cikolatali_cilekler.jpg'),
        _IdeaOption('Çikolatalı Truff', 'Truff', 'cikolatali_truff.jpg'),
        _IdeaOption('Cips ve Özel Dip Soslar', 'Dip Soslar', 'cips_dip_soslar.jpg'),
        _IdeaOption('Kadeh Şampanya/Kokteyl Eşlikçileri', 'Kokteyl Eşlik', 'kokteyl_eslikcileri.jpg'),
        _IdeaOption('Kağıt Helva Arası Dondurma/Krema', 'Kağıt Helva', 'kagit_helva_dondurma.jpg'),
        _IdeaOption('Karışık Kurabiye Tabağı', 'Kurabiye Tabağı', 'karisik_kurabiye_tabagi.jpg'),
        _IdeaOption('Karışık Meyve Şişleri', 'Meyve Şişleri', 'karisik_meyve_sisleri.jpg'),
        _IdeaOption('Karamelli Patlamış Mısır', 'Patlamış Mısır', 'karamelli_patlamis_misir.jpg'),
        _IdeaOption('Kokteyl Köfteler', 'Kokteyl Köfte', 'kokteyl_kofteler.jpg'),
        _IdeaOption('Kuruyemiş Kaseleri', 'Kuruyemiş', 'kuruyemis_kaseleri.jpg'),
        _IdeaOption('Meyveli Jöleler', 'Meyveli Jöle', 'meyveli_joleler.jpg'),
        _IdeaOption('Mini Brownie Dilimleri', 'Mini Brownie', 'mini_brownie_dilimleri.jpg'),
        _IdeaOption('Mini Pizza', 'Mini Pizza', 'mini_pizza.jpg'),
        _IdeaOption('Mini Quiche', 'Mini Quiche', 'mini_quiche.jpg'),
        _IdeaOption('Mini Sandviç Çeşitleri', 'Mini Sandviç', 'mini_sandvic_cesitleri.jpg'),
        _IdeaOption('Peynir Tabağı', 'Peynir Tabağı', 'peynir_tabagi.jpg'),
        _IdeaOption('Peynirli Milföy Çıtırları', 'Milföy Çıtır', 'peynirli_milfoy_citirlari.jpg'),
        _IdeaOption('Sebze Çubukları', 'Sebze Çubukları', 'sebze_cubuklari.jpg'),
        _IdeaOption('Somon Füme Kanepeler', 'Somon Kanepe', 'somon_fume_kanepeler.jpg'),
        _IdeaOption('Tatlı Topları', 'Tatlı Topları', 'tatli_toplari.jpg'),
      ],
    ),
    _IdeaCategory(
      key: 'anne_misafir',
      label: 'Anne Misafirliği',
      image: '$_ideasBasePath/anne_yemekleri.jpg',
      options: const [
        _IdeaOption('Anne Keki', 'Anne Keki', 'anne_keki.jpg'),
        _IdeaOption('Bisküvili Pasta', 'Bisküvili Pasta', 'biskuvili_pasta.jpg'),
        _IdeaOption('Cevizli Un Kurabiyesi', 'Un Kurabiyesi', 'cevizli_un_kurabiyesi.jpg'),
        _IdeaOption('İrmik Helvası', 'İrmik Helvası', 'irmik_helvasi.jpg'),
        _IdeaOption('Ispanaklı Börek', 'Ispanaklı Börek', 'ispanakli_borek.jpg'),
        _IdeaOption('Kakaolu Islak Kek', 'Islak Kek', 'kakaolu_islak_kek.jpg'),
        _IdeaOption('Kısır', 'Kısır', 'kisir.jpg'),
        _IdeaOption('Kupa Tatlısı', 'Kupa Tatlısı', 'kupa_tatlisi.jpg'),
        _IdeaOption('Mercimek Köftesi', 'Mercimek Köfte', 'mercimek_koftesi_ev.jpg'),
        _IdeaOption('Mücver', 'Mücver', 'mucver.jpg'),
        _IdeaOption('Nohut Salatası', 'Nohut Salata', 'nohut_salatasi.jpg'),
        _IdeaOption('Patates Salatası', 'Patates Salata', 'patates_salatasi.jpg'),
        _IdeaOption('Poğaça', 'Poğaça', 'pogaca.jpg'),
        _IdeaOption('Profiterol', 'Profiterol', 'profiterol.jpg'),
        _IdeaOption('Revani', 'Revani', 'revani.jpg'),
        _IdeaOption('Sigara Böreği', 'Sigara Böreği', 'sigara_boregi.jpg'),
        _IdeaOption('Tatlı Kurabiye', 'Tatlı Kurabiye', 'tatli_kurabiye.jpg'),
        _IdeaOption('Tepsi Böreği', 'Tepsi Böreği', 'tepsi_boregi.jpg'),
        _IdeaOption('Tuzlu Pastane Kurabiyesi', 'Tuzlu Kurabiye', 'tuzlu_pastane_kurabiyesi.jpg'),
        _IdeaOption('Zeytinyağlı Yaprak Sarma', 'Yaprak Sarma', 'zeytinyagli_yaprak_sarma_ev.jpg'),
      ],
    ),
    _IdeaCategory(
      key: 'hamur_tatli',
      label: 'Hamur ve Tatlı',
      image: '$_ideasBasePath/hamur_isleri.jpg',
      options: const [
        _IdeaOption('Bebek Eriştesi', 'Bebek Erişte', 'bebek_eristesi.jpg'),
        _IdeaOption('Burma Kadayıf', 'Burma Kadayıf', 'burma_kadayif.jpg'),
        _IdeaOption('Cevizli Burma Kadayıf', 'Cevizli Kadayıf', 'cevizli_burma_kadayif.jpg'),
        _IdeaOption('Cevizli Ev Baklavası', 'Ev Baklavası', 'cevizli_ev_baklavasi.jpg'),
        _IdeaOption('Dilber Dudağı', 'Dilber Dudağı', 'dilber_dudagi.jpg'),
        _IdeaOption('Ekmek Kadayıfı', 'Ekmek Kadayıfı', 'ekmek_kadayifi.jpg'),
        _IdeaOption('Fıstıklı Baklava', 'Fıstıklı Baklava', 'fistikli_baklava.jpg'),
        _IdeaOption('Havuç Dilimi Baklava', 'Havuç Dilim', 'havuc_dilimi_baklava.jpg'),
        _IdeaOption('Karışık Baklava Tabağı', 'Baklava Tabağı', 'karisik_baklava_tabagi.jpg'),
        _IdeaOption('Kayseri Mantısı', 'Kayseri Mantı', 'kayseri_mantisi.jpg'),
        _IdeaOption('Künefe', 'Künefe', 'kunefe.jpg'),
        _IdeaOption('Midye Baklava', 'Midye Baklava', 'midye_baklava.jpg'),
        _IdeaOption('Özel Mantı Sosu', 'Mantı Sosu', 'ozel_manti_sosu.jpg'),
        _IdeaOption('Patatesli Mantı', 'Patatesli Mantı', 'patatesli_manti.jpg'),
        _IdeaOption('Pişmemiş Kuru Erişte', 'Kuru Erişte', 'pismemis_kuru_eriste.jpg'),
        _IdeaOption('Sinop Mantısı', 'Sinop Mantı', 'sinop_mantisi.jpg'),
        _IdeaOption('Sosyete Mantısı', 'Sosyete Mantı', 'sosyete_mantisi.jpg'),
        _IdeaOption('Sütlü Nuriye', 'Sütlü Nuriye', 'sutlu_nuriye.jpg'),
        _IdeaOption('Şöbiyet', 'Şöbiyet', 'sobiyet.jpg'),
        _IdeaOption('Tel Kadayıf', 'Tel Kadayıf', 'tel_kadayif.jpg'),
      ],
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _buildIdeaAssetPath(String fileName) => '$_ideasBasePath/$fileName';

  Widget _buildIdeaImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF4E8D8),
        alignment: Alignment.center,
        child: const Icon(
          Icons.restaurant_menu,
          color: Color(0xFF9A6A3A),
          size: 28,
        ),
      ),
    );
  }

  void _openIdeaDirectly(_IdeaOption idea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRequestScreen(
          presetTitle: idea.fullTitle,
          presetImageUrl: _buildIdeaAssetPath(idea.fileName),
        ),
      ),
    );
  }

  void _openCreateRequestDirectly() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRequestScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masamda Ne Eksik')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateRequestDirectly,
        icon: const Icon(Icons.add),
        label: const Text('İlan Ver'),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _buildIdeasBanner(),
            const SizedBox(height: 20),
            _buildActiveListingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeasBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DFC3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fikir Kartları',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kararsız kaldıysan kategori seç, çeşitleri aç ve dokunarak ilanını başlat.',
            style: TextStyle(height: 1.45, color: Color(0xFF6E6253)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = _selectedCategory?.key == category.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = selected ? null : category;
                    });
                  },
                  child: SizedBox(
                    width: 116,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? const Color(0xFF8F6BF2) : const Color(0xFFE8DCC9),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildIdeaImage(category.image, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.02),
                                  Colors.black.withOpacity(0.52),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                category.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedCategory!.options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final option = _selectedCategory!.options[index];
                return GestureDetector(
                  onTap: () => _openIdeaDirectly(option),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8DCC9)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildIdeaImage(
                            _buildIdeaAssetPath(option.fileName),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            option.shortTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveListingsSection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('ownerId', isEqualTo: userId)
          .where('type', isEqualTo: 'food_request')
          .where('status', isEqualTo: 'open')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = [...(snapshot.data?.docs ?? const [])];
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>? ?? const {};
          final bData = b.data() as Map<String, dynamic>? ?? const {};
          final aCreated = aData['createdAt'];
          final bCreated = bData['createdAt'];
          if (aCreated is Timestamp && bCreated is Timestamp) {
            return bCreated.compareTo(aCreated);
          }
          if (aCreated is Timestamp) {
            return -1;
          }
          if (bCreated is Timestamp) {
            return 1;
          }
          return 0;
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Benim Aktif İlanlarım',
              subtitle: docs.isEmpty
                  ? 'Yayında ilanın yoksa sağ alttan yeni ilan açabilirsin.'
                  : 'İlanına dokunarak düzenle, sil veya öne çıkar.',
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0DFC3)),
                ),
                child: const Text('Henüz aktif ilanın yok.'),
              )
            else
              Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? 'İlan').toString();
                  final imageUrl = (data['imageUrl'] ?? '').toString();
                  final quantity = (data['quantity'] ?? '').toString();
                  final featured = data['isFeatured'] == true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestDetailScreen(
                              requestId: doc.id,
                              ownerId: userId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8DCC9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 106,
                              height: 106,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                ),
                                child: _buildListingImage(imageUrl),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (featured)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE9BA),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Öne Çıktı',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      quantity.isEmpty ? 'Miktar eklenmedi' : quantity,
                                      style: const TextStyle(color: Color(0xFF6E6253)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(height: 1.4, color: Color(0xFF6E6253)),
        ),
      ],
    );
  }

  Widget _buildListingImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _fallbackImage();
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFF3ECE0),
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood_rounded, color: Color(0xFF8B6E45), size: 32),
    );
  }
}

class _IdeaCategory {
  final String key;
  final String label;
  final String image;
  final List<_IdeaOption> options;

  const _IdeaCategory({
    required this.key,
    required this.label,
    required this.image,
    required this.options,
  });
}

class _IdeaOption {
  final String fullTitle;
  final String shortTitle;
  final String fileName;

  const _IdeaOption(this.fullTitle, this.shortTitle, this.fileName);
}
