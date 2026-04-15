import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/offer_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';
import 'package:soframda_ne_eksik/services/profile_completion_guard.dart';

class SendOfferScreen extends StatefulWidget {
  final String requestId;
  final String ownerId;
  final bool chargeCredits;

  const SendOfferScreen({
    super.key,
    required this.requestId,
    required this.ownerId,
    this.chargeCredits = true,
  });

  @override
  State<SendOfferScreen> createState() => _SendOfferScreenState();
}

class _SendOfferScreenState extends State<SendOfferScreen> {
  final TextEditingController priceController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  void _showOfferCreditsSheet() {
    PaywallService.showInsufficientCreditsSheet(
      context,
      title: 'Teklif için 5 kredi gerekiyor',
      message:
          'Teklifini hemen gönderebilmek için kredi satın alabilir, sonra kaldığın yerden devam edebilirsin.',
      buttonLabel: 'Kredi Satin Al',
      highlight: 'Teklif kredi paketleri',
    );
  }

  Future<void> _showOfferFeedback({
    required String title,
    required String message,
    IconData icon = Icons.auto_awesome_rounded,
  }) {
    return ActionFeedbackService.show(
      context,
      title: title,
      message: message,
      icon: icon,
    );
  }

  Future<void> sendOffer() async {
    if (priceController.text.trim().isEmpty) {
      await _showOfferFeedback(
        title: 'Teklif tutarını girmen gerekiyor',
        message:
            'Devam edebilmek için önce bir teklif tutarı yaz, sonra teklifini tek dokunuşla gönderebilirsin.',
        icon: Icons.edit_note_rounded,
      );
      return;
    }

    if (!await ProfileCompletionGuard.ensureDisplayNameReady(context)) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await OfferService().sendOffer(
        requestId: widget.requestId,
        ownerId: widget.ownerId,
        price: int.parse(priceController.text),
        fromChat: !widget.chargeCredits,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        Navigator.pop(context);
        await _showOfferFeedback(
          title: 'Teklifin gönderildi',
          message:
              'Teklifin ilan sahibine iletildi. Dönüş geldiğinde buradan devam edebilirsin.',
          icon: Icons.local_offer_rounded,
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) {
        return;
      }

      final message = (e.message ?? '').toLowerCase();
      final needsCredits =
          widget.chargeCredits && e.code == 'failed-precondition' && message.contains('kredi');
      if (needsCredits) {
        _showOfferCreditsSheet();
        return;
      }

      final alreadySent = message.contains('zaten teklif');
      if (alreadySent) {
        await _showOfferFeedback(
          title: 'Bu ilana teklif vermiştin',
          message:
              'Aynı ilan için ikinci kez teklif açılamıyor. Mevcut teklifini teklifler ekranından takip edebilirsin.',
          icon: Icons.local_offer_rounded,
        );
        return;
      }

      await _showOfferFeedback(
        title: 'Teklif şu an gönderilemedi',
        message: e.message ?? e.code,
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString().toLowerCase();
      final needsCredits = widget.chargeCredits && message.contains('kredi');
      if (needsCredits) {
        _showOfferCreditsSheet();
        return;
      }

      final alreadySent = message.contains('zaten teklif');
      if (alreadySent) {
        await _showOfferFeedback(
          title: 'Bu ilana teklif vermiştin',
          message:
              'Aynı ilan için ikinci kez teklif açılamıyor. Mevcut teklifini teklifler ekranından takip edebilirsin.',
          icon: Icons.local_offer_rounded,
        );
        return;
      }

      await _showOfferFeedback(
        title: 'Teklif şu an gönderilemedi',
        message: '$e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teklif Gönder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F8F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.chargeCredits
                    ? 'Bu ilana teklif göndermek 5 kredi kullanır. Teklif kabul edilirse sohbet otomatik açılır.'
                    : 'Bu sohbetten göndereceğin teklif için ek kredi düşmez. Teklif kabul edilirse sohbet kesintisiz devam eder.',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'İlk mesaj 10 kredi ile gönderilir. Sonraki mesajlar ücretsizdir.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Teklif Tutarı',
                hintText: 'Örn: 1200',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendOffer,
                child: Text(isLoading ? 'Gönderiliyor...' : 'Teklif Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
