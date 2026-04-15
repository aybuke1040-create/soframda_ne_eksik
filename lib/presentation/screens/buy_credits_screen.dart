import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/iap_service.dart';

class BuyCreditsScreen extends StatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen>
    with SingleTickerProviderStateMixin {
  final IAPService iap = IAPService();
  final CreditService _creditService = CreditService();
  late final TabController _tabController;

  bool _isClaimingShareReward = false;
  String? _activeProductId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showFeedback({
    required String title,
    required String message,
    IconData icon = Icons.auto_awesome_rounded,
  }) {
    return ActionFeedbackService.show(
      context,
      title: title,
      message: message,
      icon: icon,
    );
  }

  Future<void> _shareAppAndClaimReward() async {
    if (_isClaimingShareReward) return;

    setState(() {
      _isClaimingShareReward = true;
    });

    try {
      await Share.share(
        context.t(
          'Soframda Ne Eksik uygulamasını dene. Ev yemeği, taşıma, organizasyon ve ilanlar için birlikte üretelim.',
          'Try the Soframda Ne Eksik app. Let us create together for home meals, delivery, events, and listings.',
        ),
        subject: 'Soframda Ne Eksik',
      );

      final status = await _creditService.claimMonthlyShareReward();
      if (!mounted) return;

      if (status == MonthlyShareRewardStatus.success) {
        await _showFeedback(
          title: context.t('10 kredi kazandın', 'You earned 10 credits'),
          message: context.t(
            'Paylaşım ödülü olarak hesabına 10 kredi eklendi.',
            '10 credits were added to your account as a sharing reward.',
          ),
          icon: Icons.card_giftcard_rounded,
        );
      } else if (status == MonthlyShareRewardStatus.alreadyClaimed) {
        await _showFeedback(
          title: context.t('Bu ödülü zaten kullandın', 'You already used this reward'),
          message: context.t(
            'Paylaşım ödülü ayda sadece bir kez alınabilir. Gelecek ay tekrar deneyebilirsin.',
            'The sharing reward can only be claimed once per month. You can try again next month.',
          ),
          icon: Icons.history_rounded,
        );
      } else {
        await _showFeedback(
          title: context.t('Paylaşım ödülü şu an hazır değil', 'Share reward is not ready yet'),
          message: context.t(
            'Bu özellik şu an kullanılamıyor. Kısa süre sonra tekrar deneyebilirsin.',
            'This feature is currently unavailable. Please try again shortly.',
          ),
          icon: Icons.info_outline_rounded,
        );
      }
    } catch (_) {
      if (!mounted) return;
      await _showFeedback(
        title: context.t('Paylaşım tamamlanamadı', 'Sharing could not be completed'),
        message: context.t(
          'Uygulamayı paylaşırken bir sorun oluştu. Kısa süre sonra tekrar deneyebilirsin.',
          'There was a problem while sharing the app. Please try again shortly.',
        ),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClaimingShareReward = false;
        });
      }
    }
  }

  Future<void> _startPurchase(String productId) async {
    setState(() {
      _activeProductId = productId;
    });

    try {
      final products = await iap.loadProducts();
      final product = products.firstWhere((p) => p.id == productId);
      final result = await iap.buy(product);
      if (!mounted) return;

      await _showFeedback(
        title: result.status == PurchaseFlowStatus.success
            ? context.t('Satın alma tamamlandı', 'Purchase completed')
            : result.status == PurchaseFlowStatus.cancelled
                ? context.t('Satın alma iptal edildi', 'Purchase cancelled')
                : context.t('Satın alma tamamlanamadı', 'Purchase failed'),
        message: result.message,
        icon: result.status == PurchaseFlowStatus.success
            ? Icons.verified_rounded
            : result.status == PurchaseFlowStatus.cancelled
                ? Icons.close_rounded
                : Icons.error_outline_rounded,
      );
    } catch (_) {
      if (!mounted) return;
      await _showFeedback(
        title: context.t('Satın alma doğrulanamadı', 'Purchase could not be verified'),
        message: context.t(
          'Şu anda satın alma işlemi tamamlanamadı. Kısa süre sonra tekrar deneyebilirsin.',
          'The purchase could not be completed right now. Please try again shortly.',
        ),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _activeProductId = null;
        });
      }
    }
  }

  Widget buildPack({
    required String productId,
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    final isLoading = _activeProductId == productId;

    return GestureDetector(
      onTap: isLoading ? null : () => _startPurchase(productId),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isLoading ? 0.75 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? '$title • Hazırlanıyor...' : title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShareRewardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E4), Color(0xFFFFE4C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_outlined, color: Color(0xFF8A4B08)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t('Uygulamayı Paylaş, 10 Kredi Kazan', 'Share the App, Earn 10 Credits'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6D3906),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.t(
                  'Arkadaşlarınla paylaş, bu ay bir kez 10 kredi kazan. Her ay hakkın otomatik yenilenir.',
                  'Share it with your friends and earn 10 credits once this month. Your right renews automatically every month.',
                ),
                style: TextStyle(color: Colors.brown.shade700, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.74),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Kural', 'Rule'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D3906),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.t(
                        'Her kullanıcı ayda sadece 1 kez paylaşım ödülü alabilir.',
                        'Each user can receive the sharing reward only once per month.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isClaimingShareReward ? null : _shareAppAndClaimReward,
                  icon: const Icon(Icons.share_outlined),
                  label: Text(
                    _isClaimingShareReward
                        ? context.t('Paylaşım kontrol ediliyor...', 'Checking sharing reward...')
                        : context.t('Paylaş ve 10 kredi kazan', 'Share and earn 10 credits'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('credit_history')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(context.t('Henüz kredi geçmişi yok.', 'No credit history yet.')),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final int amount = (data['amount'] as num).toInt();
            final String action = data['action'] ?? '';
            final createdAt = data['createdAt'];
            final date = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();

            late final String title;
            late final IconData icon;
            late final Color color;

            if (amount > 0) {
              color = Colors.green;
              if (action == 'comment' || action == 'review_bonus') {
                title = context.t('+$amount kredi (yorum ödülü)', '+$amount credits (review reward)');
                icon = Icons.rate_review_rounded;
              } else if (action == 'daily_bonus') {
                title = context.t('+$amount kredi (günlük bonus)', '+$amount credits (daily bonus)');
                icon = Icons.card_giftcard_rounded;
              } else if (action == 'share_reward') {
                title = context.t('+$amount kredi (uygulamayı paylaş)', '+$amount credits (share the app)');
                icon = Icons.share_outlined;
              } else {
                title = context.t('+$amount kredi yuklendi', '+$amount credits added');
                icon = Icons.add_circle_rounded;
              }
            } else {
              color = Colors.red;
              if (action == 'create_listing' || action == 'create_request' || action == 'create_ready_food') {
                title = context.t('-10 kredi (ilan oluşturma)', '-10 credits (create listing)');
                icon = Icons.post_add_rounded;
              } else if (action == 'first_message') {
                title = context.t('-10 kredi (ilk mesaj)', '-10 credits (first message)');
                icon = Icons.chat_bubble_outline_rounded;
              } else if (action == 'send_offer' || action == 'order_ready_food') {
                title = context.t('-5 kredi (teklif gönderme)', '-5 credits (send offer)');
                icon = Icons.local_offer_rounded;
              } else if (action == 'feature') {
                title = context.t('-50 kredi (öne çıkarma)', '-50 credits (feature listing)');
                icon = Icons.star_rounded;
              } else {
                title = '$amount';
                icon = Icons.remove_circle_rounded;
              }
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(color: color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}.${date.month}.${date.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPurchaseTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildPack(
            productId: 'credits_50',
            title: '50 Kredi - 19,99 TL',
            subtitle: context.t(
              'Hızlı mesajlaşma ve teklif akışları için ideal başlangıç paketi.',
              'A great starter pack for messaging and offers.',
            ),
            colors: const [Color(0xFFF8B35A), Color(0xFFF28E1C)],
          ),
          buildPack(
            productId: 'credits_120',
            title: '120 Kredi - 39,99 TL',
            subtitle: context.t(
              'Daha aktif kullanım için avantajlı orta paket.',
              'A strong mid pack for more active usage.',
            ),
            colors: const [Color(0xFFFF9A7A), Color(0xFFF46F43)],
          ),
          buildPack(
            productId: 'credits_300',
            title: '300 Kredi - 79,99 TL',
            subtitle: context.t(
              'Yoğun kullanım için en güçlü kredi paketi.',
              'The strongest credit pack for frequent use.',
            ),
            colors: const [Color(0xFF8667F7), Color(0xFF5E35D6)],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.t('Kredi Geçmişi', 'Credit History'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: buildHistory()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Kredi Satın Al', 'Buy Credits')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.t('Paketler', 'Packages')),
            Tab(text: context.t('Paylaş Kazan', 'Share & Earn')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildPurchaseTab(),
          buildShareRewardTab(),
        ],
      ),
    );
  }
}


