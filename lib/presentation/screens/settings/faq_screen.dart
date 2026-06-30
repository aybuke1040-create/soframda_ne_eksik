import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<_FaqItem> _items = [
    _FaqItem(
      question: 'Ben Yaparım nedir ve nasıl çalışır?',
      answer:
          'Ben Yaparım; hizmet arayan kullanıcılarla evden üretim yapan, yerel hizmet sunan veya emeğiyle iş almak isteyen kişileri buluşturan mobil pazaryeri uygulamasıdır. Kullanıcı ilan açar, yakınındaki hizmet verenlerden teklif alır, teklifleri karşılaştırır ve süreci uygulama içi güvenli mesajlaşma ile yönetir.',
    ),
    _FaqItem(
      question:
          'Ben Yaparım’ın diğer hizmet ve nakliye uygulamalarından farkı nedir?',
      answer:
          'Ben Yaparım büyük ve karmaşık işler yerine yakın çevredeki pratik ihtiyaçlara odaklanır: ev yemeği, ikram, küçük taşıma, organizasyon ve tasarım gibi yerel hizmetler. Platform komisyon almaz; amaç işi en yakındaki doğru kişiyle hızlı ve zahmetsiz buluşturmaktır.',
    ),
    _FaqItem(
      question: 'Ben Yaparım üzerinden hangi ilanları açabilirim?',
      answer:
          'Ev yemeği, doğum günü pastası, davet ikramlığı, toplu yemek, hazır yemek, organizasyon, nişan veya kutlama süslemesi, açılış konsepti, küçük hacimli taşıma, parça eşya taşıma ve benzeri yerel hizmet ihtiyaçları için ilan oluşturabilirsiniz.',
    ),
    _FaqItem(
      question:
          'Evden yemek veya üretim yapan biri neden Ben Yaparım’ı kullanmalı?',
      answer:
          'Yakın çevredeki potansiyel müşterilere görünür olursunuz, profil puanı ve yorumlarla güven inşa edersiniz, teklif ve mesajları tek yerden yönetirsiniz. Ben Yaparım komisyon almadığı için kazancınız doğrudan size kalır.',
    ),
    _FaqItem(
      question: 'Ödeme süreci nasıl işler, banka veya kart bilgisi istenir mi?',
      answer:
          'Ben Yaparım iş bedellerinden komisyon almaz ve kullanıcıların banka hesap bilgisi, kart şifresi veya ödeme bilgilerini istemez. Hizmet bedeli ve ödeme yöntemi hizmet alan ile hizmet veren arasında platform dışında kararlaştırılır.',
    ),
    _FaqItem(
      question: 'Telefon numaram diğer kullanıcılara görünür mü?',
      answer:
          'Hayır. Telefon numaranız ve kişisel iletişim bilgileriniz diğer kullanıcılara gösterilmez. İlan, teklif ve hizmet detaylarını uygulama içi güvenli mesajlaşma üzerinden paylaşabilirsiniz.',
    ),
    _FaqItem(
      question: 'Yakın çevremdeki ilanlardan nasıl haberdar olurum?',
      answer:
          'Konum servisleri ve bildirimler açık olduğunda yakınınızdaki yeni ilanlar, teklifler ve mesajlar için bildirim alabilirsiniz. Böylece mahallenizdeki güncel hizmet taleplerini ve fırsatları kaçırmazsınız.',
    ),
    _FaqItem(
      question:
          'Uygulama içi kredileri nasıl kazanırım ve kredi satın alabilir miyim?',
      answer:
          'Yeni kullanıcılar hoş geldin kredisi alır. Günlük giriş ödülleri, tarif paylaşımı ve uygulama içi etkinliklerle ek kredi kazanabilirsiniz. İsterseniz küçük tutarlı kredi paketleri de satın alabilirsiniz.',
    ),
    _FaqItem(
      question: 'İlanlar neden belirli süre sonra otomatik silinir?',
      answer:
          'Platformdaki ilanların güncel kalması için süre sınırı vardır. Hazır yemek ve ev yemeği ilanları tazelik amacıyla 2 gün sonra, diğer hizmet ilanları ise genellikle 7 gün sonra otomatik olarak yayından kalkar.',
    ),
    _FaqItem(
      question: 'Ben Yaparım güvenli mi, sorun yaşarsam ne yapabilirim?',
      answer:
          'Uygulama içi mesajlaşma, profil puanı, şikayet, engelleme ve moderasyon özellikleri güvenli deneyim için tasarlanmıştır. Uygunsuz içerik, kötüye kullanım veya şüpheli davranış gördüğünüzde kullanıcıyı engelleyebilir, ilanı şikayet edebilir veya destek ekibine ulaşabilirsiniz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        title: const Text('Sıkça Sorulan Sorular'),
        backgroundColor: const Color(0xFFFFF7ED),
        foregroundColor: const Color(0xFF2D172C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7C2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFFE06B19),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ben Yaparım hakkında merak edilenler',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2D172C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlan açma, teklif alma, güvenli mesajlaşma, komisyonsuz kullanım, yakın çevre bildirimleri ve kredi sistemiyle ilgili en önemli cevapları burada bulabilirsiniz.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _KeywordChip(label: 'Ücretsiz ilan'),
                    _KeywordChip(label: 'Sıfır komisyon'),
                    _KeywordChip(label: 'Yakın çevre'),
                    _KeywordChip(label: 'Güvenli mesajlaşma'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final item in _items) _FaqTile(item: item),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE7C2)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: const Color(0xFFE06B19),
        collapsedIconColor: const Color(0xFFE06B19),
        title: Text(
          item.question,
          style: const TextStyle(
            color: Color(0xFF2D172C),
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD7A3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A3A12),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
