import 'package:flutter/material.dart';

class KvkkScreen extends StatelessWidget {
  const KvkkScreen({super.key});

  Widget _section(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KVKK'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF7F3EE), Color(0xFFECE1D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'Bu sayfa, kullanıcıların kişisel verilerinin hangi amaçlarla işlendiği ve nasıl korunduğu konusunda genel bilgilendirme sağlar.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _section(
            'Toplanan Veriler',
            'Uygulama; ad, profil fotoğrafı, e-posta veya telefon numarası, konum bilgisi, ilan ve teklif içerikleri, yorumlar ve uygulama içi hareketler gibi verileri hizmetin sunulması amacıyla işleyebilir.',
          ),
          _section(
            'İşleme Amacı',
            'Toplanan veriler; kullanıcı hesabı oluşturma, ilan yayınlama, teklif süreçlerini yönetme, kullanıcıları birbirine ulaştırma, destek süreçlerini yürütme ve güvenliği sağlama amaçlarıyla kullanılır.',
          ),
          _section(
            'Saklama ve Güvenlik',
            'Veriler, hizmetin devamlılığı ve yasal yükümlülükler kapsamında gerekli olduğu süre boyunca saklanır. Yetkisiz erişimi önlemek için teknik ve idari tedbirler uygulanır.',
          ),
          _section(
            'Kullanıcı Hakları',
            'Kullanıcılar; verilerinin işlenip işlenmediğini öğrenme, düzeltme talep etme, silme veya anonim hâle getirilmesini isteme ve itiraz haklarına sahiptir.',
          ),
          _section(
            'Başvuru ve Talep',
            'KVKK kapsamındaki taleplerinizi ayarlar içindeki Bize Ulaşın bölümünde yer alan iletişim kanalları üzerinden iletebilirsiniz. Gerektiğinde bu metin güncellenebilir.',
          ),
        ],
      ),
    );
  }
}
