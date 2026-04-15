import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/data/services/auth_service.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _verificationId;
  int? _resendToken;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _normalizePhoneNumber(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) {
      return null;
    }
    return '+90$digits';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendCode() async {
    final phoneNumber = _normalizePhoneNumber(_phoneController.text);
    if (phoneNumber == null) {
      _showMessage('Ge\u00e7erli bir telefon numaras\u0131 girin.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    await _authService.sendPhoneVerification(
      phoneNumber: phoneNumber,
      forceResendingToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        if (!mounted) {
          return;
        }

        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isSending = false;
        });

        _showMessage('Do\u011frulama kodu g\u00f6nderildi.');
      },
      onVerificationFailed: (message) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSending = false;
        });

        _showMessage(message);
      },
      onAutoVerified: (user) async {
        if (!mounted) {
          return;
        }

        await FirebaseAuth.instance.currentUser?.reload();
        _showMessage('Telefon numaras\u0131 g\u00fcncellendi.');
        Navigator.pop(context);
      },
    );
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.trim().length < 6) {
      _showMessage('6 haneli do\u011frulama kodunu girin.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await _authService.updatePhoneNumber(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      _showMessage('Telefon numaras\u0131 g\u00fcncellendi.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage(_authService.mapAuthError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
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
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8F3EC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPhone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefon Numaras\u0131'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF7F4EF), Color(0xFFECE4D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giri\u015fte kulland\u0131\u011f\u0131n telefon numaras\u0131n\u0131 buradan g\u00fcncelleyebilirsin.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                if (currentPhone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Mevcut numara: $currentPhone',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0DFC3)),
            ),
            child: const Text(
              'Not: Telefon g\u00fcncelleme i\u015flemi i\u00e7in Firebase telefon do\u011frulamas\u0131 gerekir. Uygulama do\u011frulama ayar\u0131 eksikse kod g\u00f6nderimi ba\u015far\u0131s\u0131z olabilir.',
              style: TextStyle(
                color: Color(0xFF7A6654),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              label: 'Yeni telefon numaras\u0131',
              hint: '5XX XXX XX XX',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendCode,
              child: Text(_isSending ? 'Kod g\u00f6nderiliyor...' : 'Kod G\u00f6nder'),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              label: 'SMS do\u011frulama kodu',
              hint: '6 haneli kod',
              icon: Icons.lock_outline_rounded,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyCode,
              child: Text(
                _isVerifying ? 'Do\u011frulan\u0131yor...' : 'Telefonu G\u00fcncelle',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
