import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';

import '../home/home_screen.dart';
import '../offers/offers_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  bool _tourChecked = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    OffersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkIntroTour();
  }

  List<_TourPageData> _buildTourPages(BuildContext context) {
    return [
      _TourPageData(
        title: context.t('Masamda Ne Eksik', 'What Is Missing on the Table'),
        description: context.t(
          'Aradığın lezzeti birkaç dokunuşla ilana dönüştür. Ev yemeğinden özel davet sofralarına kadar ihtiyacını yaz, sana uygun teklifler gelsin.',
          'You create a food request listing. You can collect offers for home meals, pastries, appetizers, or bulk catering.',
        ),
        icon: Icons.help_outline_rounded,
        accent: const Color(0xFFB97328),
      ),
      _TourPageData(
        title: context.t('Ben Yaparım', 'I Can Make It'),
        description: context.t(
          'Yeteneklerini kazanca dönüştür. Açık ilanları keşfet, sana uygun olanlara teklif ver ve mutfağını görünür hale getir.',
          'You browse open food requests and send offers to the ones you want. This is the main workspace for producers.',
        ),
        icon: Icons.kitchen_rounded,
        accent: const Color(0xFFB85C00),
      ),
      _TourPageData(
        title: context.t('Hazır Yemekler', 'Ready Meals'),
        description: context.t(
          'Hazır olan ürünleri anında keşfet. Fiyatı net yemekleri incele, sipariş ver ya da kendi hazırladığın tabakları vitrine çıkar.',
          'You browse meals that are already prepared with fixed prices. You can place an order or add your own item.',
        ),
        icon: Icons.restaurant_rounded,
        accent: const Color(0xFFCE7C3F),
      ),
      _TourPageData(
        title: context.t('Benim Tarifim', 'My Recipe'),
        description: context.t(
          'İlham veren tarifleri keşfet, beğendiğin bir fikri tek dokunuşla ilana çevir. Tariflerden yeni sofralar doğsun.',
          'You discover user recipes. You can start a request directly from a recipe by saying you want that dish.',
        ),
        icon: Icons.menu_book_rounded,
        accent: const Color(0xFF8C5A72),
      ),
      _TourPageData(
        title: context.t('Ben Taşırım', 'I Can Deliver'),
        description: context.t(
          'Teslimat ihtiyacını hızlıca çöz. Yemek, pasta, çiçek ya da paket taşıma işleri için doğru kişilere kolayca ulaş.',
          'Delivery listings are created for food, flowers, cakes, or packages and offers are collected.',
        ),
        icon: Icons.local_shipping_rounded,
        accent: const Color(0xFF4D88B3),
      ),
      _TourPageData(
        title: context.t('Ben Dizayn Ederim', 'I Can Design'),
        description: context.t(
          'Kutlamalarına stil kat. Doğum günü, nişan, söz ve etkinlikler için dekor ve organizasyon fikirlerini doğru kişilerle buluştur.',
          'Event and decoration offers are collected for birthdays, engagements, ceremonies, and corporate events.',
        ),
        icon: Icons.design_services_rounded,
        accent: const Color(0xFFD56A8A),
      ),
      _TourPageData(
        title: context.t('Teklifler ve Profil', 'Offers and Profile'),
        description: context.t(
          'Tekliflerini, işlerini ve profil gücünü tek yerden yönet. Yorumlarını oku, takip ağını büyüt ve hesabını canlı tut.',
          'You track the offers you send and receive, and manage your listings, jobs, reviews, and follows from your profile.',
        ),
        icon: Icons.account_circle_rounded,
        accent: const Color(0xFF6A78D1),
      ),
    ];
  }

  Future<void> _checkIntroTour() async {
    if (_tourChecked) {
      return;
    }
    _tourChecked = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final shouldHide = doc.data()?['hideIntroTour'] == true;

    if (shouldHide || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showIntroTour();
      }
    });
  }

  Future<void> _showIntroTour() async {
    final pages = _buildTourPages(context);
    final controller = PageController();
    var pageIndex = 0;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isLast = pageIndex == pages.length - 1;

            return LayoutBuilder(
              builder: (context, constraints) {
                final dialogWidth = constraints.maxWidth > 900
                    ? 760.0
                    : constraints.maxWidth > 700
                        ? 680.0
                        : constraints.maxWidth;
                final isLandscapeCompact =
                    constraints.maxWidth > constraints.maxHeight &&
                    constraints.maxHeight < 520;
                final pageHeight = isLandscapeCompact ? 300.0 : 420.0;
                final titleSize = isLandscapeCompact ? 26.0 : 34.0;
                final descSize = isLandscapeCompact ? 16.5 : 19.0;
                final iconBox = isLandscapeCompact ? 76.0 : 96.0;
                final iconSize = isLandscapeCompact ? 36.0 : 46.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: dialogWidth,
                      maxHeight: constraints.maxHeight - 32,
                    ),
                    child: Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: Text(context.t('Turu Geç', 'Skip Tour')),
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: pageHeight,
                                child: PageView.builder(
                                  controller: controller,
                                  itemCount: pages.length,
                                  onPageChanged: (value) {
                                    setDialogState(() {
                                      pageIndex = value;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: pageHeight,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: iconBox,
                                              height: iconBox,
                                              decoration: BoxDecoration(
                                                color: page.accent.withOpacity(0.14),
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              child: Icon(
                                                page.icon,
                                                size: iconSize,
                                                color: page.accent,
                                              ),
                                            ),
                                            SizedBox(height: isLandscapeCompact ? 16 : 22),
                                            Text(
                                              page.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: titleSize,
                                                fontWeight: FontWeight.w800,
                                                height: 1.08,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                page.description,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: descSize,
                                                  height: 1.65,
                                                  color: const Color(0xFF5D5347),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                pages.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: pageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: pageIndex == index
                                        ? const Color(0xFFB97328)
                                        : const Color(0xFFE3D7CA),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .set({
                                          'hideIntroTour': true,
                                        }, SetOptions(merge: true));
                                      }

                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    },
                                    child: Text(
                                      context.t('Bir Daha Gösterme', 'Do Not Show Again'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isLast) {
                                        Navigator.of(dialogContext).pop();
                                        return;
                                      }

                                      controller.nextPage(
                                        duration: const Duration(milliseconds: 220),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    child: Text(
                                      isLast
                                          ? context.t('Başla', 'Start')
                                          : context.t('Devam Et', 'Continue'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home),
        label: context.t('Ana Sayfa', 'Home'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_offer),
        label: context.t('Teklifler', 'Offers'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.person),
        label: context.t('Profil', 'Profile'),
      ),
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) {
                setState(() {
                  _index = i;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: destination.icon,
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },
        destinations: destinations,
      ),
    );
  }
}

class _TourPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  const _TourPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });
}
