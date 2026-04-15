import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/auth_wrapper.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_scope.dart';
import 'package:soframda_ne_eksik/data/services/auth_service.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/edit_profile_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/contact_us_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/kvkk_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/location_settings_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final AuthService _authService = AuthService();

  Future<void> _showLogoutSheet(BuildContext context) async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.t('\u00c7\u0131k\u0131\u015f yap\u0131ls\u0131n m\u0131?', 'Sign out?'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(
                    'Hesab\u0131ndan g\u00fcvenli \u015fekilde \u00e7\u0131k\u0131\u015f yapacaks\u0131n. \u0130stedi\u011fin zaman tekrar giri\u015f yapabilirsin.',
                    'You will securely sign out of your account. You can sign in again anytime.',
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: Text(context.t('Vazge\u00e7', 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(context.t('\u00c7\u0131k\u0131\u015f Yap', 'Sign Out')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.t('\u00c7\u0131k\u0131\u015f yap\u0131l\u0131yor...', 'Signing out...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await _authService.logout();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('Hesap silindi', 'Account deleted'))),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${context.t('Hata', 'Error')}: $e")),
      );
    }
  }

  Future<void> _showDeleteAccountSheet(BuildContext context) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.t('Hesap silinsin mi?', 'Delete account?'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(
                    'Bu i\u015flem hesab\u0131n\u0131 kal\u0131c\u0131 olarak kald\u0131r\u0131r. Eminsen devam etmeden \u00f6nce son kez kontrol et.',
                    'This action permanently removes your account. If you are sure, check once more before continuing.',
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: Text(context.t('Vazge\u00e7', 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(context.t('Hesab\u0131 Sil', 'Delete Account')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.t('Hesap siliniyor...', 'Deleting account...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await deleteAccount(context);
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Ayarlar', 'Settings')),
      ),
      body: ListView(
        children: [
          _tile(
            icon: Icons.person_outline,
            title: context.t('Profili D\u00fczenle', 'Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _tile(
            icon: Icons.notifications_none,
            title: context.t('Bildirim Ayarlar\u0131', 'Notification Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _tile(
            icon: Icons.location_on_outlined,
            title: context.t('Konum Ayarlar\u0131', 'Location Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LocationSettingsScreen(),
                ),
              );
            },
          ),
          _tile(
            icon: Icons.support_agent,
            title: context.t('Bize Ula\u015f\u0131n', 'Contact Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsScreen(),
                ),
              );
            },
          ),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: 'KVKK',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KvkkScreen(),
                ),
              );
            },
          ),
          const Divider(height: 32),
          _tile(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            textColor: Colors.red,
            title: context.t('Hesab\u0131 Sil', 'Delete Account'),
            onTap: () {
              _showDeleteAccountSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              context.t('\u00c7\u0131k\u0131\u015f Yap', 'Sign Out'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await _showLogoutSheet(context);
            },
          ),
        ],
      ),
    );
  }
}
