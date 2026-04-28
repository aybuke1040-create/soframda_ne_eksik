import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';

class CommunityTermsScreen extends StatefulWidget {
  final bool requiredAcceptance;

  const CommunityTermsScreen({
    super.key,
    this.requiredAcceptance = false,
  });

  @override
  State<CommunityTermsScreen> createState() => _CommunityTermsScreenState();
}

class _CommunityTermsScreenState extends State<CommunityTermsScreen> {
  bool _submitting = false;

  Future<void> _acceptTerms() async {
    setState(() => _submitting = true);
    try {
      await ModerationService().acceptTerms();
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _rule(String title, String body) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(height: 1.45),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.requiredAcceptance && !_submitting,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.requiredAcceptance,
          title: const Text('Topluluk Kurallari'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE9D5A7)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Icerik ve davranis kurallari',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ben Yaparim icinde ilanlar, teklifler, mesajlar ve yorumlar kullanicilar tarafindan olusturulur. Uygulamayi kullanmaya devam ederek bu kurallara uymayi kabul etmis olursun.',
                              style: TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _rule(
                        'Uygunsuz icerik yasaktir',
                        'Hakaret, nefret soylemi, taciz, cinsel icerik, tehdit, dolandiricilik, spam ve zarar verici iceriklere tolerans gostermeyiz.',
                      ),
                      _rule(
                        'Sikayet ve engelleme aktif olarak kullanilir',
                        'Bir kullaniciyi veya ilani sikayet edebilir, kotuye kullanan bir hesabi engelleyebilirsin. Engellenen kullanicinin icerigi uygulamadaki gorunumunden kaldirilir.',
                      ),
                      _rule(
                        'Moderasyon 24 saat icinde ele alinir',
                        'Raporlanan icerikler gelistirici tarafinda incelenir. Gerekirse icerik kaldirilir ve ihlal eden hesap sistemden uzaklastirilir.',
                      ),
                      _rule(
                        'Dogru ve guvenli iletisim kur',
                        'Yalnizca gercek hizmet ve ilan amaciyla iletisim kur. Yaniltici bilgi, uygunsuz yorum veya kotu niyetli teklif gonderme.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _acceptTerms,
                    child: Text(
                      _submitting
                          ? 'Kaydediliyor...'
                          : widget.requiredAcceptance
                              ? 'Kurallari kabul et ve devam et'
                              : 'Kurallari kabul ettim',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
