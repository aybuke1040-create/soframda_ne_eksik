import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:soframda_ne_eksik/presentation/screens/buy_credits_screen.dart';

class CreditBadge extends StatelessWidget {
  const CreditBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final dataMap = snapshot.data!.data() as Map<String, dynamic>?;

        final int credits = (dataMap?['credit'] is num)
            ? (dataMap!['credit'] as num).toInt()
            : 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyCreditsScreen(), // ❌ const kaldırdık
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffFFD700), Color(0xffFFA500)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  credits.toString(),
                  style: TextStyle(
                    color: credits < 20
                        ? Colors.red // 🔥 artık safe
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
