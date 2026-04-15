import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String supportEmail = 'destek@soframdaneeksik.com';
  static const String instagramHandle = '@soframdaneeksik';
  static const String businessHours = 'Hafta ici 09.00 - 18.00';

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E1D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFB96A22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
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
        title: const Text('Bize Ulasin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5EA), Color(0xFFFFE8D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sorun, oneriler veya is birlikleri icin bize ulasabilirsiniz.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'En kisa surede geri donmeye calisiyoruz.',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _infoCard(
            icon: Icons.mail_outline,
            title: 'Destek E-postasi',
            value: supportEmail,
            subtitle: 'Uygulama, odeme ve hesap konulari icin bize yazabilirsiniz.',
          ),
          _infoCard(
            icon: Icons.camera_alt_outlined,
            title: 'Instagram',
            value: instagramHandle,
            subtitle: 'Guncellemeler ve duyurular icin sosyal medya hesabimizi takip edebilirsiniz.',
          ),
          _infoCard(
            icon: Icons.schedule_outlined,
            title: 'Calisma Saatleri',
            value: businessHours,
            subtitle: 'Yogun donemlerde donus sureleri uzayabilir.',
          ),
        ],
      ),
    );
  }
}
