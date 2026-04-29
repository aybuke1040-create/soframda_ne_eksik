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
          title: const Text('Topluluk Kurallar\u0131'),
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
                              '\u0130\u00e7erik ve davran\u0131\u015f kurallar\u0131',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ben Yapar\u0131m i\u00e7inde ilanlar, teklifler, '
                              'mesajlar ve yorumlar kullan\u0131c\u0131lar '
                              'taraf\u0131ndan olu\u015fturulur. Uygulamay\u0131 '
                              'kullanmaya devam ederek bu kurallara uymay\u0131 '
                              'kabul etmi\u015f olursun.',
                              style: TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _rule(
                        'Uygunsuz i\u00e7erik yasakt\u0131r',
                        'Hakaret, nefret s\u00f6ylemi, taciz, cinsel i\u00e7erik, '
                        'tehdit, doland\u0131r\u0131c\u0131l\u0131k, spam ve zarar '
                        'verici i\u00e7eriklere tolerans g\u00f6stermeyiz.',
                      ),
                      _rule(
                        '\u015eikayet ve engelleme aktif olarak kullan\u0131l\u0131r',
                        'Bir kullan\u0131c\u0131y\u0131 veya ilan\u0131 \u015fikayet '
                        'edebilir, k\u00f6t\u00fcye kullanan bir hesab\u0131 '
                        'engelleyebilirsin. Engellenen kullan\u0131c\u0131n\u0131n '
                        'i\u00e7eri\u011fi uygulamadaki g\u00f6r\u00fcn\u00fcm\u00fcnden '
                        'kald\u0131r\u0131l\u0131r.',
                      ),
                      _rule(
                        'Moderasyon 24 saat i\u00e7inde ele al\u0131n\u0131r',
                        'Raporlanan i\u00e7erikler geli\u015ftirici taraf\u0131nda '
                        'incelenir. Gerekirse i\u00e7erik kald\u0131r\u0131l\u0131r '
                        've ihlal eden hesap sistemden uzakla\u015ft\u0131r\u0131l\u0131r.',
                      ),
                      _rule(
                        'Do\u011fru ve g\u00fcvenli ileti\u015fim kur',
                        'Yaln\u0131zca ger\u00e7ek hizmet ve ilan amac\u0131yla '
                        'ileti\u015fim kur. Yan\u0131lt\u0131c\u0131 bilgi, uygunsuz '
                        'yorum veya k\u00f6t\u00fc niyetli teklif g\u00f6nderme.',
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
                              ? 'Kurallar\u0131 kabul et ve devam et'
                              : 'Kurallar\u0131 kabul ettim',
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
