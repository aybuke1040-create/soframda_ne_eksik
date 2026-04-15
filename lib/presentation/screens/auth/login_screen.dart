import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const bool _phoneAuthEnabled = false;

  final AuthService _auth = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _codeSent = false;
  bool _useEmailAuth = true;
  bool _isEmailRegister = false;
  String _verificationId = '';
  int? _resendToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _normalizePhoneNumber(String input) {
    final digitsOnly = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digitsOnly.isEmpty) {
      return null;
    }

    if (digitsOnly.startsWith('+')) {
      if (digitsOnly.length < 12) {
        return null;
      }
      return digitsOnly;
    }

    var local = digitsOnly;
    if (local.startsWith('90')) {
      local = local.substring(2);
    }
    if (local.startsWith('0')) {
      local = local.substring(1);
    }

    if (local.length != 10) {
      return null;
    }

    return '+90$local';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _emailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Geçerli bir e-posta adresi girin.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Şifre en az 6 karakter olmalı.');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isEmailRegister) {
        await _auth.register(email, password);
        _showMessage('E-posta ile kayıt tamamlandı.');
      } else {
        await _auth.login(email, password);
      }
    } catch (error) {
      _showMessage(_auth.mapAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Şifre sıfırlama için geçerli e-posta adresini girin.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.sendPasswordResetEmail(email);
      _showMessage('Şifre sıfırlama bağlantısı e-posta adresine gönderildi.');
    } catch (error) {
      _showMessage(_auth.mapAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendCode({bool isResend = false}) async {
    final phoneNumber = _normalizePhoneNumber(_phoneController.text);
    if (phoneNumber == null) {
      _showMessage('Telefon numaranı 5XXXXXXXXX veya +90 ile gir.');
      return;
    }

    setState(() => _loading = true);

    await _auth.sendPhoneVerification(
      phoneNumber: phoneNumber,
      forceResendingToken: isResend ? _resendToken : null,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) {
          return;
        }
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken ?? _resendToken;
          _codeSent = true;
          _loading = false;
        });
        _showMessage('SMS doğrulama kodu gönderildi.');
      },
      onVerificationFailed: (message) {
        if (!mounted) {
          return;
        }
        setState(() => _loading = false);
        _showMessage(message);
      },
      onAutoVerified: (_) {
        if (!mounted) {
          return;
        }
        setState(() => _loading = false);
        _showMessage('Telefon numarası doğrulandı.');
      },
    );
  }

  Future<void> _verifyCode() async {
    final smsCode = _codeController.text.trim();
    if (_verificationId.isEmpty || smsCode.length < 6) {
      _showMessage('6 haneli SMS kodunu girin.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.verifySmsCode(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
    } catch (error) {
      _showMessage(_auth.mapAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF7B4C20)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFFEAD7BE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF7B4C20), width: 1.4),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF0A329),
          foregroundColor: const Color(0xFF3A1D07),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFF3A1D07),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildModeChip({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6E3DB6) : Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF6E3DB6) : const Color(0xFFE5D7F8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF5A4282),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF3F3058),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final headline = _useEmailAuth
        ? (_isEmailRegister
            ? 'Hesabını birkaç adımda oluştur.'
            : 'E-posta ile güvenli giriş yap.')
        : (_codeSent
            ? 'Kod geldi, şimdi doğrulayalım.'
            : 'Telefonunla hızlıca devam et.');

    final subtitle = _useEmailAuth
        ? (_isEmailRegister
            ? 'İlanlara, tekliflere ve organizasyon planlarına tek yerden ulaş.'
            : 'Sana özel ilan, teklif ve mesaj akışına kaldığın yerden dön.')
        : (_codeSent
            ? 'Telefonuna gelen 6 haneli kodu gir, hesabın hemen açılsın.'
            : 'Mahallendeki yemek, ikram ve organizasyon fırsatlarını birkaç dokunuşla keşfet.');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A2FA3),
            Color(0xFF7A3FC1),
            Color(0xFF8D59D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A2FA3).withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              padding: const EdgeInsets.all(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/ben_yaparim_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'BEN YAPARIM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          if (_phoneAuthEnabled)
            Row(
              children: [
                _buildModeChip(
                  title: 'Telefon',
                  icon: Icons.phone_iphone_rounded,
                  selected: !_useEmailAuth,
                  onTap: () {
                    setState(() {
                      _useEmailAuth = false;
                      _codeSent = false;
                      _verificationId = '';
                      _codeController.clear();
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildModeChip(
                  title: 'E-posta',
                  icon: Icons.alternate_email_rounded,
                  selected: _useEmailAuth,
                  onTap: () {
                    setState(() {
                      _useEmailAuth = true;
                      _codeSent = false;
                      _verificationId = '';
                      _codeController.clear();
                    });
                  },
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_read_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kapalı testte giriş e-posta ile devam ediyor.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSurface({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF0E3D1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF9F2EA),
              Color(0xFFF8EEDD),
              Color(0xFFF6EFE9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    _buildSurface(
                      children: _useEmailAuth
                          ? [
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(
                                  label: 'E-posta adresi',
                                  hint: 'ornek@mail.com',
                                  icon: Icons.alternate_email_rounded,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _inputDecoration(
                                  label: 'Şifre',
                                  hint: 'En az 6 karakter',
                                  icon: Icons.lock_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _buildPrimaryButton(
                                label: _isEmailRegister ? 'Kaydol ve Başla' : 'Giriş Yap',
                                onPressed: _loading ? null : _emailAuth,
                              ),
                              const SizedBox(height: 10),
                              if (!_isEmailRegister)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _loading ? null : _resetPassword,
                                    child: const Text('Şifremi Unuttum'),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isEmailRegister = !_isEmailRegister;
                                        });
                                      },
                                child: Text(
                                  _isEmailRegister
                                      ? 'Zaten hesabın var mı? Giriş yap'
                                      : 'Hesabın yok mu? Kaydol',
                                ),
                              ),
                            ]
                          : (!_codeSent
                              ? [
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: _inputDecoration(
                                      label: 'Telefon numarası',
                                      hint: '5XX XXX XX XX',
                                      icon: Icons.phone_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8EE),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFF0DFC3)),
                                    ),
                                    child: const Text(
                                      'Numaranı 5XXXXXXXXX ya da +905XXXXXXXXX formatında girebilirsin.',
                                      style: TextStyle(
                                        color: Color(0xFF7F6A57),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _buildPrimaryButton(
                                    label: 'SMS Kodu Gönder',
                                    onPressed: _loading ? null : _sendCode,
                                  ),
                                ]
                              : [
                                  TextField(
                                    controller: _codeController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    decoration: _inputDecoration(
                                      label: 'SMS doğrulama kodu',
                                      hint: '6 haneli kod',
                                      icon: Icons.verified_outlined,
                                    ).copyWith(counterText: ''),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _normalizePhoneNumber(_phoneController.text) ??
                                        _phoneController.text,
                                    style: const TextStyle(
                                      color: Color(0xFF7F756D),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _buildPrimaryButton(
                                    label: 'Girişi Tamamla',
                                    onPressed: _loading ? null : _verifyCode,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () {
                                            setState(() {
                                              _codeSent = false;
                                              _verificationId = '';
                                              _codeController.clear();
                                            });
                                          },
                                    child: const Text('Numarayı Değiştir'),
                                  ),
                                  TextButton(
                                    onPressed: _loading ? null : () => _sendCode(isResend: true),
                                    child: const Text('Kodu Tekrar Gönder'),
                                  ),
                                ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
