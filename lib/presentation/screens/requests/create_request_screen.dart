import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soframda_ne_eksik/core/utils/content_moderation_utils.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final String? presetTitle;
  final String? presetDescription;
  final String? presetImageUrl;
  final String? requestId;
  final bool isReady;

  const CreateRequestScreen({
    super.key,
    this.presetTitle,
    this.presetDescription,
    this.presetImageUrl,
    this.requestId,
    this.isReady = false,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  static const int _createRequestCreditCost = 10;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _portionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  bool get _isEditing => widget.requestId != null;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.presetTitle ?? '';
    _descriptionController.text = widget.presetDescription ?? '';
    _existingImageUrl = widget.presetImageUrl;

    _titleController.addListener(_refreshPreview);
    _descriptionController.addListener(_refreshPreview);
    _quantityController.addListener(_refreshPreview);

    if (_isEditing) {
      _loadRequest();
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshPreview);
    _descriptionController.removeListener(_refreshPreview);
    _quantityController.removeListener(_refreshPreview);
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  String _normalizeQuantity(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return '';

    final normalized = trimmed.replaceAll(',', '.');
    final isOnlyNumber = RegExp(r'^\d+([.]\d+)?$').hasMatch(normalized);
    if (isOnlyNumber && !widget.isReady) {
      return '$trimmed kişilik';
    }
    return trimmed;
  }

  Future<void> _loadRequest() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
      final data = doc.data();
      if (data == null) return;

      _titleController.text = (data['title'] ?? '').toString();
      _descriptionController.text = (data['description'] ?? '').toString();
      _quantityController.text = (data['quantity'] ?? '').toString();
      _priceController.text = data['price']?.toString() ?? '';
      _portionController.text = data['portion']?.toString() ?? '';
      _existingImageUrl = data['imageUrl'] as String?;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  Future<void> saveRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    final moderationIssue = findObjectionableContent({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'quantity': _quantityController.text,
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

    setState(() => _isLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final ownerName = ((userData['name'] as String?) ?? '').trim().isNotEmpty
          ? (userData['name'] as String).trim()
          : 'Kullanıcı';

      final position = await Geolocator.getCurrentPosition();
      final geo = GeoFirePoint(GeoPoint(position.latitude, position.longitude));

      final requestRef = _isEditing
          ? FirebaseFirestore.instance.collection('requests').doc(widget.requestId)
          : FirebaseFirestore.instance.collection('requests').doc();

      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('requests').child('${requestRef.id}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final data = <String, dynamic>{
        'id': requestRef.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'quantity': _normalizeQuantity(_quantityController.text),
        'ownerId': user.uid,
        'ownerName': ownerName,
        'userName': ownerName,
        'imageUrl': imageUrl,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': geo.data,
        'type': widget.isReady ? 'ready_food' : 'food_request',
        'isReady': widget.isReady,
        'price': widget.isReady ? int.tryParse(_priceController.text.trim()) : null,
        'portion': widget.isReady ? int.tryParse(_portionController.text.trim()) : null,
        'status': 'open',
      };

      if (_isEditing) {
        await requestRef.update({...data, 'updatedAt': FieldValue.serverTimestamp()});
      } else {
        final success = await CreditService().performAction(
          userId: user.uid,
          cost: _createRequestCreditCost,
          actionName: widget.isReady ? 'create_ready_food' : 'create_request',
          onSuccess: () async {
            await requestRef.set({
              ...data,
              'createdAt': FieldValue.serverTimestamp(),
              'expiresAt': buildPublicExpiryTimestamp(
                requestType: widget.isReady ? 'ready_food' : 'food_request',
                isReady: widget.isReady,
              ),
            });
          },
        );
        if (!success) {
          throw Exception('İlan vermek için $_createRequestCreditCost kredi gerekiyor.');
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
      await ActionFeedbackService.show(
        context,
        title: _isEditing ? 'İlan güncellendi' : 'İlan yayınlandı',
        message: _isEditing
            ? 'İlanındaki değişiklikler kaydedildi.'
            : 'İlanın başarıyla yayınlandı. Artık ilgili kişiler seni görebilir.',
        icon: _isEditing ? Icons.edit_rounded : Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      if (message.contains('kredi')) {
        PaywallService.showInsufficientCreditsSheet(
          context,
          title: 'İlan vermek için $_createRequestCreditCost kredi gerekiyor',
          message: 'İlanını hemen yayınlamak için önce kredi satın alabilir, sonra kaldığın yerden devam edebilirsin.',
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.isReady
        ? (_isEditing ? 'Hazır Yemeği Düzenle' : 'Hazır Yemek Ekle')
        : (_isEditing ? 'Masamda Ne Eksik İlanını Düzenle' : 'Masamda Ne Eksik İlanı');

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (!widget.isReady) _buildCompactIntro(),
                      if (!widget.isReady) const SizedBox(height: 16),
                      _buildImagePicker(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık',
                          hintText: 'Örn: 20 kişilik börek ve sarma istiyorum',
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Başlık gir' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: widget.isReady ? 'Açıklama' : 'Detay',
                          hintText: widget.isReady
                              ? 'Yemeğin içeriğini, sunumunu ve teslim bilgisini kısaca paylaş'
                              : 'İstediğin yemeği, kaç kişilik olduğunu ve varsa küçük notlarını buraya yazabilirsin',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: widget.isReady ? 'Miktar' : 'Porsiyon / kişi / adet',
                          hintText: widget.isReady ? 'Örn: 6 porsiyon' : 'Örn: 15 kişilik, 2 tepsi, 40 adet',
                        ),
                      ),
                      if (widget.isReady) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Fiyat'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _portionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Porsiyon'),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        _buildPreviewCard(),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: saveRequest,
                        child: Text(_isEditing ? 'Kaydet' : widget.isReady ? '10 Kredi ile Hazır Yemeği Yayınla' : '10 Kredi ile İlan Ver'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCompactIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DFC3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İlanını birkaç net cümleyle anlatman yeterli.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('İstediğin yemeği, miktarı ve sana uygun zamanı yazarsan ilgilenen kişiler sana daha rahat dönüş yapabilir.', style: TextStyle(height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget imageChild;
    if (_imageFile != null) {
      imageChild = Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      imageChild = _existingImageUrl!.startsWith('assets/')
          ? Image.asset(_existingImageUrl!, fit: BoxFit.cover)
          : Image.network(_existingImageUrl!, fit: BoxFit.cover);
    } else {
      imageChild = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 34),
          SizedBox(height: 8),
          Text('Kapak görseli ekle'),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
        child: imageChild,
      ),
    );
  }

  Widget _buildPreviewCard() {
    final title = _titleController.text.trim();
    final quantity = _normalizeQuantity(_quantityController.text);
    final description = _descriptionController.text.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0DFC3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('İlan özeti', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Text(title.isEmpty ? 'Başlık eklendiğinde burada görünecek.' : title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(quantity.isEmpty ? 'Miktar bilgisi henüz girilmedi.' : quantity, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(
            description.isEmpty ? 'Birkaç küçük detay eklemen ilanını daha anlaşılır hale getirir.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800, height: 1.4),
          ),
        ],
      ),
    );
  }
}
