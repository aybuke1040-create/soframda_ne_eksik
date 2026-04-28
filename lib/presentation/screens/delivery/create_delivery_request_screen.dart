import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soframda_ne_eksik/core/utils/content_moderation_utils.dart';
import 'package:soframda_ne_eksik/core/utils/location_utils.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/delivery_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';
import 'package:soframda_ne_eksik/services/storage_service.dart';

class CreateDeliveryRequestScreen extends StatefulWidget {
  final String? presetTitle;
  final String? presetDescription;
  final String? requestId;

  const CreateDeliveryRequestScreen({
    super.key,
    this.presetTitle,
    this.presetDescription,
    this.requestId,
  });

  @override
  State<CreateDeliveryRequestScreen> createState() =>
      _CreateDeliveryRequestScreenState();
}

class _CreateDeliveryRequestScreenState
    extends State<CreateDeliveryRequestScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  DateTime? selectedDateTime;
  File? image;
  String? existingImageUrl;
  bool loading = false;

  bool get _isEditing => widget.requestId != null;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.presetTitle ?? '';
    descController.text = widget.presetDescription ?? '';

    titleController.addListener(_refreshPreview);
    descController.addListener(_refreshPreview);
    pickupController.addListener(_refreshPreview);
    dropController.addListener(_refreshPreview);

    if (_isEditing) {
      _loadRequest();
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_refreshPreview);
    descController.removeListener(_refreshPreview);
    pickupController.removeListener(_refreshPreview);
    dropController.removeListener(_refreshPreview);
    titleController.dispose();
    descController.dispose();
    pickupController.dispose();
    dropController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadRequest() async {
    setState(() => loading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .get();
      final data = doc.data();

      if (data == null || !mounted) {
        return;
      }

      titleController.text = data['title']?.toString() ?? '';
      descController.text = data['description']?.toString() ?? '';
      pickupController.text = data['pickupAddress']?.toString() ?? '';
      dropController.text = data['dropAddress']?.toString() ?? '';
      existingImageUrl = data['imageUrl']?.toString();

      final deliveryTime = data['deliveryTime']?.toString() ?? '';
      if (deliveryTime.isNotEmpty) {
        selectedDateTime = DateTime.tryParse(deliveryTime);
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) {
      return;
    }

    setState(() {
      selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> createRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final moderationIssue = findObjectionableContent({
      'title': titleController.text,
      'description': descController.text,
      'pickupAddress': pickupController.text,
      'dropAddress': dropController.text,
    });
    if (moderationIssue != null) {
      await ActionFeedbackService.show(
        context,
        title: 'Icerik gonderilemedi',
        message:
            'Topluluk kurallarina aykiri gorunen bir ifade tespit edildi. Lutfen metni duzeltip tekrar deneyin.',
        icon: Icons.report_gmailerrorred_rounded,
      );
      return;
    }

    setState(() => loading = true);

    try {
      String imageUrl = '';
      if (image != null) {
        imageUrl = await StorageService().uploadDeliveryImage(image!);
      } else if (existingImageUrl != null) {
        imageUrl = existingImageUrl!;
      }

      final pos = await getUserLocation();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .update({
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          'pickupAddress': pickupController.text.trim(),
          'dropAddress': dropController.text.trim(),
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'deliveryTime': selectedDateTime?.toIso8601String() ?? '',
          'imageUrl': imageUrl,
          'ownerId': user.uid,
          'ownerName': userData['name'] ?? 'Kullanıcı',
          'requestType': 'delivery',
          'status': 'open',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final success = await CreditService().performAction(
          userId: user.uid,
          cost: 10,
          actionName: 'create_request',
          onSuccess: () async {
            await DeliveryService().createDeliveryRequest(
              title: titleController.text.trim(),
              description: descController.text.trim(),
              pickupAddress: pickupController.text.trim(),
              dropAddress: dropController.text.trim(),
              latitude: pos.latitude,
              longitude: pos.longitude,
              deliveryTime: selectedDateTime?.toIso8601String() ?? '',
              imageUrl: imageUrl,
              ownerId: user.uid,
              ownerName: userData['name'] ?? 'Kullanıcı',
            );
          },
        );

        if (!mounted) {
          return;
        }

        if (!success) {
          throw Exception('Taşıma ilanı vermek için 10 kredi gerekiyor.');
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      await ActionFeedbackService.show(
        context,
        title: _isEditing ? 'İlan güncellendi' : 'İlan yayına alındı',
        message: _isEditing
            ? 'Taşıma ilanı güncellendi.'
            : 'Taşıma ilanı yayına alındı.',
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString().toLowerCase();
      if (message.contains('kredi')) {
        PaywallService.showInsufficientCreditsSheet(
          context,
          title: 'Taşıma ilanı vermek için 10 kredi gerekiyor',
          message:
              'Taşıma ilanını yayınlamak için önce kredi satın alabilir, sonra işlemini tamamlayabilirsin.',
          buttonLabel: 'Kredi Satın Al',
          highlight: 'Sana uygun kredi paketleri',
        );
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'İşlem tamamlanamadı',
        message: '$e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Taşıma İlanını Düzenle' : 'Taşıma İlanı'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildChecklistCard(),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.grey.shade200,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: image == null
                          ? (existingImageUrl != null &&
                                  existingImageUrl!.isNotEmpty)
                              ? Image.network(existingImageUrl!,
                                  fit: BoxFit.cover)
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 36),
                                      SizedBox(height: 8),
                                      Text(
                                          'Taşıma ürünü veya paket görseli ekle'),
                                    ],
                                  ),
                                )
                          : Image.file(image!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText:
                          'Örn: Kadıköyden Beşiktaşa 3 tepsi yemek taşınacak',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detay',
                      hintText:
                          'Taşıma şekli, hassasiyet, kat bilgisi veya teslim notlarını yaz.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Nereden Alınacak',
                      hintText: 'Örn: Fenerbahçe Mahallesi, apartman girişi',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dropController,
                    decoration: const InputDecoration(
                      labelText: 'Nereye Bırakılacak',
                      hintText: 'Örn: Levent, plaza girişi',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: pickDateTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      selectedDateTime == null
                          ? 'Tarih ve Saat Seç'
                          : '${selectedDateTime!.day}.${selectedDateTime!.month}.${selectedDateTime!.year} ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewCard(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : createRequest,
                      child: Text(
                        loading
                            ? 'Yayınlanıyor...'
                            : _isEditing
                                ? 'Değişiklikleri Kaydet'
                                : '10 Kredi ile Premium İlan Ver',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF8FF), Color(0xFFDCEEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium taşıma ilanı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nereden alınacağını, nereye bırakılacağını ve ne zaman teslim edileceğini net yaz. Taşıyıcılar sana daha hızlı teklif gönderebilir.',
            style: TextStyle(height: 1.45),
          ),
          SizedBox(height: 10),
          Text(
            'İlan yayına alma bedeli: 10 kredi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C6E99),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE8F1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daha iyi teklif için bunları ekle',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 10),
          _DeliveryChecklistItem(text: 'Taşıma ürününün ne olduğu'),
          _DeliveryChecklistItem(text: 'Alış ve bırakış adresi'),
          _DeliveryChecklistItem(text: 'Tarih ve saat bilgisi'),
          _DeliveryChecklistItem(text: 'Hassasiyet veya ek notlar'),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final title = titleController.text.trim();
    final detail = descController.text.trim();
    final pickup = pickupController.text.trim();
    final drop = dropController.text.trim();
    final schedule = selectedDateTime == null
        ? 'Tarih seçilmedi'
        : '${selectedDateTime!.day}.${selectedDateTime!.month}.${selectedDateTime!.year} ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE8F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İlan özeti',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title.isEmpty ? 'Başlık burada görünecek.' : title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(pickup.isEmpty ? 'Alış noktası girilmedi' : 'Alış: $pickup'),
          const SizedBox(height: 4),
          Text(drop.isEmpty ? 'Bırakış noktası girilmedi' : 'Bırak: $drop'),
          const SizedBox(height: 4),
          Text(schedule),
          const SizedBox(height: 8),
          Text(
            detail.isEmpty
                ? 'Detay girdiğinde taşıyıcılar işini daha doğru fiyatlar.'
                : detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DeliveryChecklistItem extends StatelessWidget {
  final String text;

  const _DeliveryChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF2C6E99),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
