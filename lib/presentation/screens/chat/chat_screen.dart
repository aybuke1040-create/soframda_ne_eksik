import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/offers/send_offer_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/chat_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';
import 'package:soframda_ne_eksik/services/offer_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';
import 'package:soframda_ne_eksik/services/profile_completion_guard.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? initialRequestId;
  final String? initialOfferId;
  final int? initialOfferPrice;
  final String? initialDraftText;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.initialRequestId,
    this.initialOfferId,
    this.initialOfferPrice,
    this.initialDraftText,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  String otherUserName = 'Sohbet';
  String otherUserId = '';
  String requestId = '';
  String pendingOfferId = '';
  int? pendingOfferPrice;
  bool _isAccepting = false;
  bool _isSendingMessage = false;
  bool _canSendOffer = false;
  String? _pendingOutgoingText;

  Future<String?> _pickModerationReason({
    required String title,
  }) async {
    const reasons = <String>[
      'Hakaret veya taciz',
      'Uygunsuz içerik',
      'Spam veya dolandırıcılık',
      'Tehdit veya güvensiz davranış',
      'Diğer',
    ];

    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...reasons.map((reason) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      onTap: () => Navigator.pop(sheetContext, reason),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reportUser() async {
    if (otherUserId.isEmpty) {
      return;
    }
    final reason = await _pickModerationReason(
      title: 'Bu kullanıcıyı neden şikayet etmek istiyorsun?',
    );
    if (reason == null) {
      return;
    }

    await ModerationService().reportUser(
      targetUserId: otherUserId,
      reason: reason,
    );

    if (!mounted) {
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: 'Şikayet alındı',
      message:
          '$otherUserName hakkındaki bildirimini aldık. Moderasyon ekibimiz 24 saat içinde inceleyecek.',
      icon: Icons.flag_outlined,
    );
  }

  Future<void> _blockUser() async {
    if (otherUserId.isEmpty) {
      return;
    }
    final reason = await _pickModerationReason(
      title: 'Bu kullanıcıyı neden engellemek istiyorsun?',
    );
    if (reason == null) {
      return;
    }

    await ModerationService().blockUser(
      targetUserId: otherUserId,
      targetName: otherUserName,
    );

    if (!mounted) {
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: 'Kullanıcı engellendi',
      message:
          '$otherUserName artık akışında ve mesaj listende görünmeyecek.',
      icon: Icons.block_rounded,
    );
    Navigator.pop(context);
  }

  Future<void> _unblockUser() async {
    if (otherUserId.isEmpty) {
      return;
    }

    await ModerationService().unblockUser(targetUserId: otherUserId);

    if (!mounted) {
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: 'Engel kaldırıldı',
      message:
          '$otherUserName için engel kaldırıldı. İçerikleri yeniden görünmeye başlayacak.',
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  void initState() {
    super.initState();
    ChatService().resetUnread(widget.chatId);
    requestId = widget.initialRequestId ?? '';
    pendingOfferId = widget.initialOfferId ?? '';
    pendingOfferPrice = widget.initialOfferPrice;
    controller.text = widget.initialDraftText ?? '';
    loadChatContext();
  }

  Future<void> loadChatContext() async {
    final doc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    final data = doc.data();
    if (data == null) {
      return;
    }

    final users = List<String>.from(data['users'] ?? []);
    final currentRequestId = (data['requestId'] ?? '').toString();
    final otherId = users.firstWhere(
      (id) => id != user.uid,
      orElse: () => '',
    );

    String resolvedName = 'Sohbet';
    if (otherId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .get();
      resolvedName = (userDoc.data()?['name'] ?? 'Kullanıcı').toString();
    }

    String nextPendingOfferId = '';
    int? nextPendingOfferPrice;
    bool nextCanSendOffer = false;

    if (currentRequestId.isNotEmpty && otherId.isNotEmpty) {
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(currentRequestId)
          .get();
      final requestData = requestDoc.data() ?? <String, dynamic>{};
      final ownerId = (requestData['ownerId'] ?? '').toString();
      final requestStatus = (requestData['status'] ?? 'open').toString();
      final isRequestOwner = ownerId == user.uid;

      if (isRequestOwner && requestStatus == 'open') {
        final offerDoc = await FirebaseFirestore.instance
            .collection('offers')
            .doc('${currentRequestId}_$otherId')
            .get();
        final offerData = offerDoc.data() ?? <String, dynamic>{};

        if (offerDoc.exists &&
            (offerData['status'] ?? 'pending').toString() == 'pending') {
          nextPendingOfferId = offerDoc.id;
          final rawPrice = offerData['price'];
          if (rawPrice is int) {
            nextPendingOfferPrice = rawPrice;
          } else if (rawPrice is num) {
            nextPendingOfferPrice = rawPrice.toInt();
          }
        }
      }

      if (!isRequestOwner && requestStatus == 'open') {
        final myOfferDoc = await FirebaseFirestore.instance
            .collection('offers')
            .doc('${currentRequestId}_${user.uid}')
            .get();
        nextCanSendOffer = !myOfferDoc.exists;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      otherUserId = otherId;
      otherUserName = resolvedName;
      requestId = currentRequestId;
      if (pendingOfferId.isEmpty) {
        pendingOfferId = nextPendingOfferId;
      }
      pendingOfferPrice ??= nextPendingOfferPrice;
      _canSendOffer = nextCanSendOffer;
    });
  }

  Future<void> acceptPendingOffer() async {
    if (pendingOfferId.isEmpty || requestId.isEmpty) {
      return;
    }

    setState(() {
      _isAccepting = true;
    });

    try {
      await OfferService().acceptOffer(
        offerId: pendingOfferId,
        requestId: requestId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        pendingOfferId = '';
        pendingOfferPrice = null;
      });

      await ActionFeedbackService.show(
        context,
        title: 'Teklif kabul edildi',
        message: 'Teklif kabul edildi.',
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Teklif kabul edilemedi',
        message: 'Teklif kabul edilemedi: $e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> openOfferSheet() async {
    if (requestId.isEmpty || otherUserId.isEmpty) {
      return;
    }

    if (!await ProfileCompletionGuard.ensureDisplayNameReady(context)) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendOfferScreen(
          requestId: requestId,
          ownerId: otherUserId,
          chargeCredits: false,
        ),
      ),
    );

    await loadChatContext();
  }

  Future<void> sendMessage() async {
    final draftText = controller.text.trim();
    if (draftText.isEmpty || _isSendingMessage) {
      return;
    }

    if (!await ProfileCompletionGuard.ensureDisplayNameReady(context)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSendingMessage = true;
      _pendingOutgoingText = draftText;
      controller.clear();
    });

    try {
      await ChatService().sendMessage(
        chatId: widget.chatId,
        text: draftText,
        senderId: user.uid,
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) {
        return;
      }

      if (controller.text.trim().isEmpty) {
        controller.text = draftText;
      }

      final message = (e.message ?? '').toLowerCase();
      final needsCredits = message.contains('10 kredi') ||
          message.contains('kredi') ||
          e.code == 'failed-precondition';

      if (needsCredits) {
        PaywallService.showInsufficientCreditsSheet(
          context,
          title: 'Mesaj için 10 kredi gerekiyor',
          message:
              'İlk mesajı gönderebilmek için önce kredi satın alabilirsin. Sonraki mesajlar ücretsiz devam eder.',
          buttonLabel: 'Kredi Satın Al',
        );
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Mesaj gönderilemedi',
        message: e.message ?? e.code,
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      if (controller.text.trim().isEmpty) {
        controller.text = draftText;
      }

      final fallbackMessage = e.toString();
      if (fallbackMessage.toLowerCase().contains('kredi')) {
        PaywallService.showInsufficientCreditsSheet(
          context,
          title: 'Mesaj için 10 kredi gerekiyor',
          message:
              'İlk mesajı gönderebilmek için önce kredi satın alabilirsin. Sonraki mesajlar ücretsiz devam eder.',
          buttonLabel: 'Kredi Satın Al',
        );
      } else {
        await ActionFeedbackService.show(
          context,
          title: 'Mesaj gönderilemedi',
          message: fallbackMessage,
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
          _pendingOutgoingText = null;
        });
      }
    }
  }

  Widget _buildAcceptBanner() {
    if (pendingOfferId.isEmpty) {
      return const SizedBox.shrink();
    }

    final priceText = pendingOfferPrice == null
        ? 'Bu sohbet için bekleyen bir teklif var.'
        : 'Bu sohbette ₺$pendingOfferPrice tutarında bekleyen teklif var.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4E2), Color(0xFFFFE5BF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0B46A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5A2B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFF8B5A2B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              priceText,
              style: const TextStyle(
                color: Color(0xFF5C3B16),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A2B),
              foregroundColor: Colors.white,
            ),
            onPressed: _isAccepting ? null : acceptPendingOffer,
            child: Text(_isAccepting ? 'Bekleyin...' : 'Teklifi Kabul Et'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOfferButton() {
    if (!_canSendOffer) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6D4B8)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bu sohbetten teklif verebilirsin. Ek teklif için tekrar kredi düşmez.',
              style: TextStyle(
                color: Color(0xFF5B4630),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: openOfferSheet,
            child: const Text('Teklif Ver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
        actions: [
          StreamBuilder<Set<String>>(
            stream: ModerationService().watchBlockedUserIds(),
            builder: (context, snapshot) {
              final blockedIds = snapshot.data ?? const <String>{};
              final isBlocked = otherUserId.isNotEmpty &&
                  blockedIds.contains(otherUserId);

              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'report') {
                    await _reportUser();
                  }
                  if (value == 'block') {
                    await _blockUser();
                  }
                  if (value == 'unblock') {
                    await _unblockUser();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Kullanıcıyı Şikayet Et'),
                  ),
                  PopupMenuItem<String>(
                    value: isBlocked ? 'unblock' : 'block',
                    child: Text(
                      isBlocked
                          ? 'Engeli Kaldır'
                          : 'Kullanıcıyı Engelle',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAcceptBanner(),
          _buildChatOfferButton(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService().getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                final extraCount = _pendingOutgoingText == null ? 0 : 1;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  itemCount: messages.length + extraCount,
                  itemBuilder: (context, index) {
                    if (_pendingOutgoingText != null && index == 0) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 260),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pendingOutgoingText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                 const Text(
                                   'Gönderiliyor...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final messageIndex = index - extraCount;
                    final data =
                        messages[messageIndex].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user.uid;
                    final text = (data['text'] ?? '').toString();

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.orange : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      enabled: !_isSendingMessage,
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: IconButton(
                      icon: _isSendingMessage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.orange),
                      onPressed: _isSendingMessage ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
