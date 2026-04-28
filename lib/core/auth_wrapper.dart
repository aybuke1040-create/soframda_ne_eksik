import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main/main_screen.dart';
import '../presentation/screens/settings/community_terms_screen.dart';
import '../services/moderation_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return StreamBuilder<bool>(
            stream: ModerationService().watchTermsAccepted(),
            builder: (context, termsSnapshot) {
              if (!termsSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (termsSnapshot.data == true) {
                return const MainScreen();
              }

              return const CommunityTermsScreen(requiredAcceptance: true);
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
