import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService();

  static const String _phoneFallbackMessage =
      'Dilersen e-posta seçeneğiyle devam edebilir ya da destek için '
      'benyaparimci@gmail.com adresine yazabilirsin.';

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleSignInInitialization;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  bool _requiresEmailVerification(User user) {
    return user.email != null &&
        !user.emailVerified &&
        user.providerData.any((provider) => provider.providerId == 'password');
  }

  bool requiresEmailVerification(User user) {
    return _requiresEmailVerification(user);
  }

  Future<void> _useTurkishAuthEmails() {
    return _auth.setLanguageCode('tr');
  }

  Future<void> _sendVerificationEmail(User user) async {
    if (!user.emailVerified) {
      await _useTurkishAuthEmails();
      await user.sendEmailVerification();
    }
  }

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null) {
      if (_requiresEmailVerification(user)) {
        try {
          await _sendVerificationEmail(user);
        } on FirebaseAuthException catch (error) {
          if (error.code != 'too-many-requests') {
            rethrow;
          }
        }
        await _auth.signOut();
        throw FirebaseAuthException(code: 'email-not-verified');
      }

      await createUserIfNotExists(user);
    }

    return user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null) {
      try {
        await createUserIfNotExists(user);
        await _sendVerificationEmail(user);
      } finally {
        await _auth.signOut();
      }
    }

    return user;
  }

  Future<User?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Google ile giriş bu platformda desteklenmiyor.',
      );
    }

    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google kimlik bilgisi alınamadı.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        await createUserIfNotExists(user);
      }

      return user;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }

      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: error.description,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _useTurkishAuthEmails();
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onVerificationFailed,
    void Function(User user)? onAutoVerified,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            await createUserIfNotExists(user);
            onAutoVerified?.call(user);
          }
        } on FirebaseAuthException catch (error) {
          onVerificationFailed(mapAuthError(error));
        } catch (_) {
          onVerificationFailed(
            'Telefon doğrulaması şu anda tamamlanamadı. '
            '$_phoneFallbackMessage',
          );
        }
      },
      verificationFailed: (error) {
        onVerificationFailed(mapAuthError(error));
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      // Android'in otomatik SMS okuma süresinin dolması, yeni bir kodun
      // gönderildiği anlamına gelmez. Ekrandaki doğrulama kimliğini ve yeniden
      // gönderme jetonunu burada değiştirmiyoruz; kullanıcı mevcut kodu elle
      // girmeye devam edebilir.
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<User?> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    if (user != null) {
      await createUserIfNotExists(user);
    }

    return user;
  }

  Future<void> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Aktif kullanıcı bulunamadı.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await user.updatePhoneNumber(credential);
    await user.reload();

    final refreshedUser = _auth.currentUser;
    if (refreshedUser != null) {
      await createUserIfNotExists(refreshedUser);
    }
  }

  Future<void> logout() async {
    try {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // Firebase oturumu yine de kapatılmalı.
    }
    await _auth.signOut();
  }

  Future<void> createUserIfNotExists(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    final existingData = doc.data() ?? <String, dynamic>{};
    final existingName = (existingData['name'] as String? ?? '').trim();
    final authDisplayName = (user.displayName ?? '').trim();
    final publicName = existingName.isNotEmpty
        ? existingName
        : (authDisplayName.isNotEmpty ? authDisplayName : 'Kullanıcı');
    final publicPhotoUrl = (existingData['photoUrl'] as String? ?? '').trim();

    final payload = {
      'name': publicName,
      'photoUrl': publicPhotoUrl,
      'ratingAverage': existingData['ratingAverage'] ?? 0,
      'ratingCount': existingData['ratingCount'] ?? 0,
      'recipesCount': existingData['recipesCount'] ?? 0,
      'completedOrders': existingData['completedOrders'] ?? 0,
      'createdAt': doc.exists
          ? (existingData['createdAt'] ?? FieldValue.serverTimestamp())
          : FieldValue.serverTimestamp(),
    };

    await userRef.set(payload, SetOptions(merge: true));
    await userRef.collection('private').doc('account').set({
      'phoneNumber': user.phoneNumber ?? '',
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await userRef.set({
      'phoneNumber': FieldValue.delete(),
      'email': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  String mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      final message = (error.message ?? '').toLowerCase();

      if (message.contains('valid app identifier') ||
          message.contains('play integrity') ||
          message.contains('recaptcha')) {
        return 'Telefon doğrulaması bu cihazda başlatılamadı. '
            '$_phoneFallbackMessage';
      }

      switch (error.code) {
        case 'invalid-phone-number':
          return 'Telefon numarası geçersiz görünüyor. '
              'Numaranı kontrol edip tekrar deneyebilir ya da e-posta '
              'seçeneğine geçebilirsin.';
        case 'too-many-requests':
          return 'Kısa sürede çok fazla deneme yapıldı. Biraz sonra tekrar '
              'deneyebilir ya da e-posta ile devam edebilirsin.';
        case 'invalid-verification-code':
          return 'SMS doğrulama kodu hatalı görünüyor. İstersen yeni kod '
              'iste ya da e-posta seçeneğine geç.';
        case 'session-expired':
          return 'Kodun süresi dolmuş. Yeni kod isteyebilir ya da e-posta '
              'seçeneğiyle devam edebilirsin.';
        case 'network-request-failed':
          return 'İnternet bağlantını kontrol edip tekrar dene. Sorun '
              'sürerse e-posta seçeneğini kullanabilirsin.';
        case 'email-not-verified':
          return 'E-posta adresini doğrulaman gerekiyor. Sana doğrulama '
              'bağlantısı gönderdik; gelen kutunu ve spam klasörünü kontrol et.';
        case 'unauthorized-continue-uri':
        case 'invalid-continue-uri':
        case 'missing-continue-uri':
          return 'E-posta doğrulama bağlantısı şu anda hazırlanamadı. '
              'Lütfen destek ekibiyle iletişime geç ya da biraz sonra tekrar dene.';
        case 'missing-google-id-token':
        case 'google-sign-in-failed':
          return 'Google ile giriş şu anda tamamlanamadı. Lütfen tekrar dene '
              'veya telefon/e-posta seçeneğini kullan.';
        case 'app-not-authorized':
        case 'captcha-check-failed':
        case 'missing-client-identifier':
        case 'missing-phone-number':
          return 'Telefon doğrulaması şu anda kullanılamıyor. '
              '$_phoneFallbackMessage';
        case 'invalid-email':
          return 'Geçerli bir e-posta adresi gir.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Bu bilgilerle eşleşen kayıtlı bir hesap bulunamadı. '
              'E-posta adresini ve şifreni kontrol et veya "Kaydol" '
              'seçeneğiyle yeni hesap oluştur.';
        case 'user-disabled':
          return 'Bu hesap kullanıma kapatılmış. Destek ekibiyle iletişime geç.';
        case 'email-already-in-use':
          return 'Bu e-posta adresiyle daha önce kayıt oluşturulmuş. '
              '"Giriş Yap" seçeneğini kullan veya şifreni sıfırla.';
        case 'weak-password':
          return 'Şifre yeterince güçlü değil. En az 6 karakterden oluşan '
              'daha güçlü bir şifre belirle.';
        case 'operation-not-allowed':
          return 'Bu giriş yöntemi şu anda kullanılamıyor. '
              'Lütfen daha sonra tekrar dene.';
        case 'no-current-user':
          return 'Bu işlem için önce hesabına giriş yapmalısın.';
        default:
          return 'Giriş işlemi tamamlanamadı. Bilgilerini kontrol edip tekrar '
              'dene. Hesabın yoksa "Kaydol" seçeneğini kullan.';
      }
    }

    return 'Giriş işlemi tamamlanamadı. İnternet bağlantını ve bilgilerini '
        'kontrol edip tekrar dene.';
  }

  String mapEmailLoginError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Bu e-posta ve şifreyle eşleşen kayıtlı bir hesap bulunamadı. '
              'Bilgilerini kontrol et veya hesabın yoksa "Kaydol" seçeneğini kullan.';
        default:
          return mapAuthError(error);
      }
    }

    return mapAuthError(error);
  }

  String mapPhoneAuthError(Object error) {
    if (error is FirebaseAuthException) {
      final message = (error.message ?? '').toLowerCase();

      if (message.contains('valid app identifier') ||
          message.contains('play integrity') ||
          message.contains('recaptcha')) {
        return 'Telefon doğrulaması bu test ortamında başlatılamadı. '
            'Android veya iOS cihazda tekrar dene ya da e-posta seçeneğiyle devam et.';
      }

      switch (error.code) {
        case 'invalid-credential':
        case 'invalid-verification-id':
          return 'Telefon doğrulama oturumu geçersiz görünüyor. Yeni SMS kodu isteyip tekrar dene.';
        case 'invalid-verification-code':
          return 'SMS doğrulama kodu hatalı görünüyor. Kodu kontrol et veya yeni kod iste.';
        case 'captcha-check-failed':
        case 'app-not-authorized':
        case 'missing-client-identifier':
          return 'Telefonla giriş bu Chrome test ortamında tamamlanamadı. '
              'Firebase web yetkilendirmesi veya reCAPTCHA ayarı gerekebilir. '
              'Sürüm testi için Android/iOS cihazda dene.';
        default:
          return mapAuthError(error);
      }
    }

    return mapAuthError(error);
  }
}
