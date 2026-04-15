import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/edit_profile_screen.dart';

class ProfileCompletionGuard {
  static Future<bool> ensureDisplayNameReady(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final profileName = (userDoc.data()?['name'] ?? '').toString().trim();
    final normalizedName = profileName.toLowerCase();
    const invalidNames = {
      '',
      'kullanici',
      'kullanıcı',
      'user',
    };

    if (!invalidNames.contains(normalizedName)) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final shouldEdit = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFFD88912),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Profilini tamamlaman gerekiyor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Devam etmeden Ã¶nce profil sekmesinden kullanıcı adÄ±nÄ±zÄ± dÃ¼zenleyiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6B6B6B),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0A329),
                          foregroundColor: const Color(0xFF3A1D07),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Profili Düzenle',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Şimdilik Vazgeç'),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    if (shouldEdit && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        ),
      );
    }

    return false;
  }
}
