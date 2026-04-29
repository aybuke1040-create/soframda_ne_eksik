import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null) {
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
      await createUserIfNotExists(user);
    }

    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
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
            'Telefon doğrulaması tamamlanamadı. Lütfen tekrar deneyin.',
          );
        }
      },
      verificationFailed: (error) {
        onVerificationFailed(mapAuthError(error));
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        onCodeSent(verificationId, forceResendingToken);
      },
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
        message: 'Aktif kullanici bulunamadi.',
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
        : (authDisplayName.isNotEmpty ? authDisplayName : 'Kullanici');
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
        return 'Telefon doğrulaması başlatılamadı. Firebase tarafında com.benyaparim.app için SHA-1 / SHA-256 ve Phone sağlayıcısı ayarlarını kontrol etmen gerekiyor.';
      }

      switch (error.code) {
        case 'invalid-phone-number':
          return 'Telefon numarası geçersiz görünüyor.';
        case 'too-many-requests':
          return 'Çok fazla deneme yapıldı. Biraz sonra tekrar deneyin.';
        case 'invalid-verification-code':
          return 'SMS doğrulama kodu hatalı.';
        case 'session-expired':
          return 'Kodun süresi doldu. Lütfen yeni kod isteyin.';
        case 'network-request-failed':
          return 'İnternet bağlantısını kontrol edip tekrar deneyin.';
        case 'app-not-authorized':
          return 'Bu uygulama telefon doğrulaması için henüz yetkilendirilmemiş görünüyor.';
        default:
          return error.message ?? 'Giriş sırasında bir hata oluştu.';
      }
    }

    return error.toString();
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Telefon numaras\u0131 ge\u00e7ersiz g\u00f6r\u00fcn\u00fcyor.';
      case 'too-many-requests':
        return '\u00c7ok fazla deneme yap\u0131ld\u0131. Biraz sonra tekrar deneyin.';
      case 'invalid-verification-code':
        return 'SMS do\u011frulama kodu hatal\u0131.';
      case 'session-expired':
        return 'Kodun s\u00fcresi doldu. L\u00fctfen yeni kod isteyin.';
      case 'network-request-failed':
        return '\u0130nternet ba\u011flant\u0131s\u0131n\u0131 kontrol edip tekrar deneyin.';
      default:
        return error.message ?? 'Giri\u015f s\u0131ras\u0131nda bir hata olu\u015ftu.';
    }
  }
}
