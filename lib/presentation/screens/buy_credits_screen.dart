import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/app_share_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/iap_service.dart';
import 'package:soframda_ne_eksik/services/rewarded_ad_service.dart';

class BuyCreditsScreen extends StatefulWidget {
  const BuyCreditsScreen({super.key});

  @override
  State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen>
    with SingleTickerProviderStateMixin {
  final IAPService iap = IAPService();
  final CreditService _creditService = CreditService();
  final RewardedAdService _rewardedAdService = RewardedAdService();
  final AppShareService _appShareService = const AppShareService();
  late final TabController _tabController;

  bool _isClaimingShareReward = false;
  bool _isWatchingRewardedAd = false;
  bool _isPreparingRewardedAd = true;
  bool _isRewardedAdReady = false;
  String? _rewardedAdSessionId;
  String? _activeProductId;
  bool _isLoadingStoreProducts = true;
  Map<String, ProductDetails> _storeProducts = const {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareRewardedAd());
      unawaited(_loadStoreProducts());
    });
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _prepareRewardedAd() async {
    if (_rewardedAdService.isReady ||
        (_isPreparingRewardedAd && _rewardedAdSessionId != null)) {
      return;
    }

    if (mounted) {
      setState(() {
        _isPreparingRewardedAd = true;
        _isRewardedAdReady = false;
      });
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final sessionId = await _creditService.createRewardedAdSession();
    if (userId == null || sessionId == null) {
      if (mounted) setState(() => _isPreparingRewardedAd = false);
      return;
    }

    final loaded = await _rewardedAdService.preload(
      userId: userId,
      sessionId: sessionId,
    );
    if (!mounted) return;

    setState(() {
      _isPreparingRewardedAd = false;
      _isRewardedAdReady = loaded;
      _rewardedAdSessionId = loaded ? sessionId : null;
    });
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

  Future<void> _loadStoreProducts() async {
    try {
      final products = await iap.loadProducts();
      if (!mounted) return;
      setState(() {
        _storeProducts = {for (final product in products) product.id: product};
        _isLoadingStoreProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingStoreProducts = false);
    }
  }

  Future<void> _shareAppAndClaimReward() async {
    if (_isClaimingShareReward) return;

    final appLink = defaultTargetPlatform == TargetPlatform.iOS
        ? 'https://apps.apple.com/app/id6762226701'
        : 'https://play.google.com/store/apps/details?id=com.benyaparim.app';

    setState(() {
      _isClaimingShareReward = true;
    });

    try {
      final shareStatus = await _appShareService.shareText(
        context,
        message: context.t(
          'Ben Yaparım ile ev yemeği, taşıma, organizasyon ve diğer ihtiyaçların için yakınındaki kişilerle kolayca buluş. Sen de katıl: $appLink',
          'Use Ben Yaparım to connect with people nearby for home meals, delivery, events, listings, and more. Join us: $appLink',
        ),
        subject: 'Ben Yaparım',
      );

      if (!mounted || shareStatus == AppShareStatus.dismissed) return;
      if (shareStatus == AppShareStatus.unavailable) {
        await _showFeedback(
          title: context.t(
            'Paylaşım tamamlanamadı',
            'Sharing could not be completed',
          ),
          message: context.t(
            'Cihazında kullanılabilir bir paylaşım uygulaması bulunamadı.',
            'No sharing app is available on your device.',
          ),
          icon: Icons.error_outline_rounded,
        );
        return;
      }

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
          title: context.t(
              'Bu ödülü zaten kullandın', 'You already used this reward'),
          message: context.t(
            'Paylaşım ödülü ayda sadece bir kez alınabilir. Gelecek ay tekrar deneyebilirsin.',
            'The sharing reward can only be claimed once per month. You can try again next month.',
          ),
          icon: Icons.history_rounded,
        );
      } else {
        await _showFeedback(
          title: context.t('Paylaşım ödülü şu an hazır değil',
              'Share reward is not ready yet'),
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
        title: context.t(
            'Paylaşım tamamlanamadı', 'Sharing could not be completed'),
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

  Future<void> _watchRewardedAdAndClaimCredit() async {
    if (_isWatchingRewardedAd || !_isRewardedAdReady) return;

    setState(() {
      _isWatchingRewardedAd = true;
    });

    try {
      final currentStatus = await _creditService.getRewardedAdCreditStatus();
      if (!mounted) return;

      if (currentStatus.status == RewardedAdCreditStatus.dailyLimitReached) {
        await _showFeedback(
          title: context.t(
              'Günlük ödül limiti doldu', 'Daily reward limit reached'),
          message: context.t(
            'Bugün reklam izleyerek en fazla 10 kredi kazanabilirsin. Yarın tekrar deneyebilirsin.',
            'You can earn up to 10 credits per day from ads. Try again tomorrow.',
          ),
          icon: Icons.lock_clock_rounded,
        );
        return;
      }

      final completed = await _rewardedAdService.showPreloadedAd();
      if (!mounted) return;

      setState(() {
        _isRewardedAdReady = false;
        _rewardedAdSessionId = null;
      });
      unawaited(_prepareRewardedAd());

      if (!completed) {
        await _showFeedback(
          title: context.t('Reklam tamamlanmadı', 'Ad was not completed'),
          message: context.t(
            'Kredi kazanmak için reklamı sonuna kadar izlemen gerekiyor.',
            'Watch the ad until the end to earn credits.',
          ),
          icon: Icons.info_outline_rounded,
        );
        return;
      }

      final result = await _creditService.waitForRewardedAdVerification(
        previousStatus: currentStatus,
      );
      if (!mounted) return;

      if (result.status == RewardedAdCreditStatus.rewardGranted) {
        await _showFeedback(
          title: context.t(
            '${result.creditsAwarded} kredi kazandın',
            'You earned ${result.creditsAwarded} credits',
          ),
          message: context.t(
            '2 reklamı tamamladığın için hesabına ${result.creditsAwarded} kredi eklendi. Bugün reklamdan toplam ${result.dailyCreditsEarned} kredi kazandın.',
            'You completed 2 ads, so ${result.creditsAwarded} credits were added. You earned ${result.dailyCreditsEarned} ad credits today.',
          ),
          icon: Icons.play_circle_fill_rounded,
        );
      } else if (result.status == RewardedAdCreditStatus.dailyLimitReached) {
        await _showFeedback(
          title: context.t(
              'Günlük ödül limiti doldu', 'Daily reward limit reached'),
          message: context.t(
            'Bugün reklam izleyerek en fazla 10 kredi kazanabilirsin. Yarın tekrar deneyebilirsin.',
            'You can earn up to 10 credits per day from ads. Try again tomorrow.',
          ),
          icon: Icons.lock_clock_rounded,
        );
      } else if (result.status == RewardedAdCreditStatus.progress) {
        await _showFeedback(
          title: context.t('1 reklam tamamlandı', '1 ad completed'),
          message: context.t(
            'Bir reklam daha izlersen 5 kredi kazanacaksın.',
            'Watch one more ad to earn 5 credits.',
          ),
          icon: Icons.play_circle_outline_rounded,
        );
      } else {
        await _showFeedback(
          title: context.t('Ödül doğrulanıyor', 'Reward is being verified'),
          message: context.t(
            'Reklam tamamlandı. Sunucu doğrulaması gecikirse kredi kısa süre içinde otomatik olarak hesabına eklenir.',
            'The ad was completed. If server verification is delayed, credits will be added automatically shortly.',
          ),
          icon: Icons.error_outline_rounded,
        );
      }
    } catch (_) {
      if (!mounted) return;
      await _showFeedback(
        title: context.t('Reklam açılamadı', 'Ad could not be opened'),
        message: context.t(
          'Şu anda uygun reklam bulunamadı. Kısa süre sonra tekrar deneyebilirsin.',
          'No ad is available right now. Please try again shortly.',
        ),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWatchingRewardedAd = false;
        });
      }
    }
  }

  Future<void> _startPurchase(String productId) async {
    setState(() {
      _activeProductId = productId;
    });

    try {
      var product = _storeProducts[productId];
      if (product == null) {
        await _loadStoreProducts();
        product = _storeProducts[productId];
      }

      if (product == null) {
        if (!mounted) return;
        await _showFeedback(
          title: context.t(
            'Kredi paketi mağazada bulunamadı',
            'Credit pack was not found in the store',
          ),
          message: context.t(
            '$productId ürünü Google Play tarafından uygulamaya döndürülmedi. Play Console ürün kimliği, aktiflik durumu, ülke/fiyat ve test yayınını kontrol et.',
            '$productId was not returned by Google Play. Check the Play Console product id, active status, country/price, and test release.',
          ),
          icon: Icons.storefront_outlined,
        );
        return;
      }

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
        title: context.t(
            'Satın alma doğrulanamadı', 'Purchase could not be verified'),
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
    required String creditLabel,
    required String subtitle,
    required List<Color> colors,
  }) {
    final isLoading = _activeProductId == productId;
    final storeProduct = _storeProducts[productId];
    final priceLabel = storeProduct?.price ??
        (_isLoadingStoreProducts
            ? context.t('Fiyat yükleniyor...', 'Loading price...')
            : context.t('Mağazada mevcut değil', 'Not available in store'));
    final title = '$creditLabel • $priceLabel';

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
                color: colors.last.withValues(alpha: 0.22),
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
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.24)),
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
                        color: Colors.white.withValues(alpha: 0.92),
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

  Widget buildRewardedAdPack() {
    final isBusy = _isPreparingRewardedAd || _isWatchingRewardedAd;
    final isEnabled = _isRewardedAdReady && !_isWatchingRewardedAd;
    final status = _isPreparingRewardedAd
        ? context.t('Reklam hazırlanıyor...', 'Preparing ad...')
        : _isWatchingRewardedAd
            ? context.t('Reklam doğrulanıyor...', 'Verifying ad...')
            : _isRewardedAdReady
                ? context.t('2 reklam izle • 5 kredi kazan',
                    'Watch 2 ads • Earn 5 credits')
                : context.t(
                    'Reklam şu an hazır değil', 'Ad is not ready right now');

    return GestureDetector(
      onTap: isEnabled ? _watchRewardedAdAndClaimCredit : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isEnabled || isBusy ? 1 : 0.68,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BFA7), Color(0xFF168B7C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF168B7C).withValues(alpha: 0.22),
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
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Ücretsiz Kredi', 'Free Credits'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isBusy)
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
                      context.t('Uygulamayı Paylaş, 10 Kredi Kazan',
                          'Share the App, Earn 10 Credits'),
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
                  color: Colors.white.withValues(alpha: 0.74),
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
                  onPressed:
                      _isClaimingShareReward ? null : _shareAppAndClaimReward,
                  icon: const Icon(Icons.share_outlined),
                  label: Text(
                    _isClaimingShareReward
                        ? context.t('Paylaşım kontrol ediliyor...',
                            'Checking sharing reward...')
                        : context.t('Paylaş ve 10 kredi kazan',
                            'Share and earn 10 credits'),
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
            child: Text(context.t(
                'Henüz kredi geçmişi yok.', 'No credit history yet.')),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final int amount = (data['amount'] as num).toInt();
            final String action = data['action'] ?? '';
            final createdAt = data['createdAt'];
            final date =
                createdAt is Timestamp ? createdAt.toDate() : DateTime.now();

            late final String title;
            late final IconData icon;
            late final Color color;

            if (amount > 0) {
              color = Colors.green;
              if (action == 'comment' || action == 'review_bonus') {
                title = context.t('+$amount kredi (yorum ödülü)',
                    '+$amount credits (review reward)');
                icon = Icons.rate_review_rounded;
              } else if (action == 'daily_bonus') {
                title = context.t('+$amount kredi (günlük bonus)',
                    '+$amount credits (daily bonus)');
                icon = Icons.card_giftcard_rounded;
              } else if (action == 'share_reward') {
                title = context.t('+$amount kredi (uygulamayı paylaş)',
                    '+$amount credits (share the app)');
                icon = Icons.share_outlined;
              } else if (action == 'rewarded_ad') {
                title = context.t('+$amount kredi (reklam ödülü)',
                    '+$amount credits (ad reward)');
                icon = Icons.play_circle_fill_rounded;
              } else {
                title = context.t(
                    '+$amount kredi yuklendi', '+$amount credits added');
                icon = Icons.add_circle_rounded;
              }
            } else {
              color = Colors.red;
              if (action == 'create_listing' ||
                  action == 'create_request' ||
                  action == 'create_ready_food') {
                title = context.t('$amount kredi (ilan oluşturma)',
                    '$amount credits (create listing)');
                icon = Icons.post_add_rounded;
              } else if (action == 'first_message') {
                title = context.t('$amount kredi (ilk mesaj)',
                    '$amount credits (first message)');
                icon = Icons.chat_bubble_outline_rounded;
              } else if (action == 'send_offer' ||
                  action == 'order_ready_food') {
                title = context.t('$amount kredi (teklif gönderme)',
                    '$amount credits (send offer)');
                icon = Icons.local_offer_rounded;
              } else if (action == 'feature') {
                title = context.t('$amount kredi (öne çıkarma)',
                    '$amount credits (feature listing)');
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
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}.${date.month}.${date.year}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
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
            creditLabel: context.t('50 Kredi', '50 Credits'),
            subtitle: context.t(
              'Hızlı mesajlaşma ve teklif akışları için ideal başlangıç paketi.',
              'A great starter pack for messaging and offers.',
            ),
            colors: const [Color(0xFFF8B35A), Color(0xFFF28E1C)],
          ),
          buildPack(
            productId: 'credits_120',
            creditLabel: context.t('120 Kredi', '120 Credits'),
            subtitle: context.t(
              'Daha aktif kullanım için avantajlı orta paket.',
              'A strong mid pack for more active usage.',
            ),
            colors: const [Color(0xFFFF9A7A), Color(0xFFF46F43)],
          ),
          buildPack(
            productId: 'credits_300',
            creditLabel: context.t('300 Kredi', '300 Credits'),
            subtitle: context.t(
              'Yoğun kullanım için en güçlü kredi paketi.',
              'The strongest credit pack for frequent use.',
            ),
            colors: const [Color(0xFF8667F7), Color(0xFF5E35D6)],
          ),
          buildRewardedAdPack(),
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
