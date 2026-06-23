import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(
    text: 'Ben Yaparım güncellendi',
  );
  final _bodyController = TextEditingController(
    text:
        'Yeni ilanları ve mesajları kaçırmamak için uygulamanı güncelleyip bildirimlerini açmanı öneririz. Desteğin için teşekkür ederiz.',
  );
  final _actionLabelController = TextEditingController(text: 'Güncellemeyi Aç');
  final _actionUrlController = TextEditingController(
    text: 'https://play.google.com/store/apps/details?id=com.benyaparim.app',
  );
  final _durationController = TextEditingController(text: '14');
  bool _sendPush = true;
  bool _showOnOpen = true;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _actionLabelController.dispose();
    _actionUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate() || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final days = int.tryParse(_durationController.text.trim()) ?? 14;
      final callable =
          FirebaseFunctions.instance.httpsCallable('createAdminBroadcast');
      final result = await callable.call<Map<String, dynamic>>({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'actionLabel': _actionLabelController.text.trim(),
        'actionUrl': _actionUrlController.text.trim(),
        'showOnOpen': _showOnOpen,
        'sendPush': _sendPush,
        'durationDays': days,
      });

      final data = result.data;
      final notificationCount = data['notificationCount'] ?? 0;

      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Bildirim hazırlandı',
        message:
            'Duyuru kaydedildi. $notificationCount kullanıcı için bildirim kuyruğa alındı.',
        icon: Icons.check_circle_outline_rounded,
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Bildirim gönderilemedi',
        message:
            error.message ?? 'Yetki veya bağlantı nedeniyle tamamlanamadı.',
        icon: Icons.error_outline_rounded,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Bildirim gönderilemedi',
        message: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan gerekli.';
    }
    return null;
  }

  String? _validateDuration(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 1 || parsed > 30) {
      return '1 ile 30 gün arasında olmalı.';
    }
    return null;
  }

  String? _validateOptionalUrl(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Geçerli bir bağlantı girin.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Bildirim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0DFC3)),
            ),
            child: const Text(
              'Bu ekrandan gönderilen duyuru, bildirim izni açık kullanıcılara push olarak gider. Bildirimi kapalı olan kullanıcılar da uygulamayı açınca aynı mesajı görür.',
              style: TextStyle(height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyController,
                  maxLength: 240,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Mesaj',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _actionLabelController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Buton yazısı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _actionUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Buton bağlantısı',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateOptionalUrl,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Uygulama açılışında kaç gün gösterilsin?',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateDuration,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push bildirimi de gönder'),
                  subtitle: const Text(
                    'Bildirim izni açık kullanıcılara telefon bildirimi gider.',
                  ),
                  value: _sendPush,
                  onChanged: (value) => setState(() => _sendPush = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Uygulama açılınca göster'),
                  subtitle: const Text(
                    'Bildirim kapalı olsa bile kullanıcı uygulamada görür.',
                  ),
                  value: _showOnOpen,
                  onChanged: (value) => setState(() => _showOnOpen = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendBroadcast,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.campaign_outlined),
                    label: Text(
                      _isSending ? 'Gönderiliyor...' : 'Herkese Gönder',
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
}
