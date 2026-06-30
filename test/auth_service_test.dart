import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soframda_ne_eksik/data/services/auth_service.dart';

void main() {
  group('AuthService.mapAuthError', () {
    final authService = AuthService();

    test('kayitli olmayan hesap icin Turkce yonlendirme verir', () {
      final message = authService.mapAuthError(
        FirebaseAuthException(code: 'user-not-found'),
      );

      expect(message, contains('kayıtlı bir hesap bulunamadı'));
      expect(message, contains('Kaydol'));
    });

    test('yeni invalid-credential kodunu Turkce yonlendirmeye cevirir', () {
      final message = authService.mapAuthError(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      expect(message, contains('kayıtlı bir hesap bulunamadı'));
      expect(message, contains('Kaydol'));
    });

    test('bilinmeyen teknik hatayi kullaniciya gostermez', () {
      final message = authService.mapAuthError(
        FirebaseAuthException(
          code: 'unknown-error',
          message: 'Internal technical failure',
        ),
      );

      expect(message, isNot(contains('Internal technical failure')));
      expect(message, contains('Giriş işlemi tamamlanamadı'));
    });

    test('telefon invalid-credential hatasini sms oturumu olarak aciklar', () {
      final message = authService.mapPhoneAuthError(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      expect(message, contains('Telefon doğrulama oturumu'));
      expect(message, contains('Yeni SMS kodu'));
    });

    test('eposta invalid-credential hatasini kayit yonlendirmesiyle aciklar',
        () {
      final message = authService.mapEmailLoginError(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      expect(message, contains('e-posta ve şifreyle'));
      expect(message, contains('Kaydol'));
    });
  });
}
