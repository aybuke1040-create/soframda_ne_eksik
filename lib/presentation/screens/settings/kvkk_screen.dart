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
              'Bu sayfa, kullanicilarin kisel verilerinin hangi amaclarla islendigi ve nasil korundugu konusunda genel bilgilendirme saglar.',
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
            'Uygulama; ad, profil fotografi, e-posta veya telefon numarasi, konum bilgisi, ilan ve teklif icerikleri, yorumlar ve uygulama ici hareketler gibi verileri hizmetin sunulmasi amaciyla isleyebilir.',
          ),
          _section(
            'Isleme Amaci',
            'Toplanan veriler; kullanici hesabi olusturma, ilan yayinlama, teklif sureclerini yonetme, kullanicilari birbirine ulastirma, destek sureclerini yurutme ve guvenligi saglama amaclariyla kullanilir.',
          ),
          _section(
            'Saklama ve Guvenlik',
            'Veriler, hizmetin devamliligi ve yasal yukumlulukler kapsaminda gerekli oldugu sure boyunca saklanir. Yetkisiz erisimi onlemek icin teknik ve idari tedbirler uygulanir.',
          ),
          _section(
            'Kullanici Haklari',
            'Kullanicilar; verilerinin islenip islenmedigini ogrenme, duzeltme talep etme, silme veya anonim hale getirilmesini isteme ve itiraz haklarina sahiptir.',
          ),
          _section(
            'Basvuru ve Talep',
            'KVKK kapsamindaki taleplerinizi ayarlar icindeki Bize Ulasin bolumunde yer alan iletisim kanallari uzerinden iletebilirsiniz. Gerektiginde bu metin guncellenebilir.',
          ),
        ],
      ),
    );
  }
}
