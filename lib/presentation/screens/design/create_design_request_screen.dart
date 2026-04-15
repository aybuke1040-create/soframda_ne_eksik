import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soframda_ne_eksik/core/utils/location_utils.dart';
import 'package:soframda_ne_eksik/core/utils/request_visibility_utils.dart';
import 'package:soframda_ne_eksik/services/credit_service.dart';
import 'package:soframda_ne_eksik/services/paywall_service.dart';

class CreateDesignRequestScreen extends StatefulWidget {
  final String? presetTitle;
  final String? presetCategory;
  final String? requestId;

  const CreateDesignRequestScreen({
    super.key,
    this.presetTitle,
    this.presetCategory,
    this.requestId,
  });

  @override
  State<CreateDesignRequestScreen> createState() =>
      _CreateDesignRequestScreenState();
}

class _CreateDesignRequestScreenState extends State<CreateDesignRequestScreen> {
  final titleController = TextEditingController();
  final guestController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  String category = '';
  File? imageFile;
  String? existingImageUrl;
  bool isSubmitting = false;

  bool get _isEditing => widget.requestId != null;

  final Map<String, String> categories = const {
    'dogum_gunu': 'Dogum Gunu',
    'baby_shower': 'Baby Shower',
    'nisan': 'Nisan',
    'bekarliga_veda': 'Bekarliga Veda',
    'kurumsal': 'Kurumsal Etkinlik',
    'dugun': 'Dugun',
    'masa_duzeni': 'Masa Duzeni',
    'backdrop': 'Backdrop Tasarimi',
    'stand': 'Stand Tasarimi',
    'diger': 'Diger',
  };

  @override
  void initState() {
    super.initState();
    titleController.text = widget.presetTitle ?? '';
    category = widget.presetCategory ?? '';

    titleController.addListener(_refreshPreview);
    guestController.addListener(_refreshPreview);
    dateController.addListener(_refreshPreview);
    locationController.addListener(_refreshPreview);
    descriptionController.addListener(_refreshPreview);

    if (_isEditing) {
      _loadRequest();
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_refreshPreview);
    guestController.removeListener(_refreshPreview);
    dateController.removeListener(_refreshPreview);
    locationController.removeListener(_refreshPreview);
    descriptionController.removeListener(_refreshPreview);
    titleController.dispose();
    guestController.dispose();
    locationController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadRequest() async {
    setState(() => isSubmitting = true);

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
      guestController.text = (data['guestCount'] ?? '').toString();
      locationController.text = data['location']?.toString() ?? '';
      dateController.text = data['date']?.toString() ?? '';
      descriptionController.text = data['description']?.toString() ?? '';
      category = data['category']?.toString() ?? '';
      existingImageUrl = data['imageUrl']?.toString();
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) {
      return null;
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('design_requests')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(imageFile!);
    return ref.getDownloadURL();
  }

  Future<void> createRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || titleController.text.trim().isEmpty) {
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final pos = await getUserLocation();
      final requestRef = _isEditing
          ? FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.requestId)
          : FirebaseFirestore.instance.collection('requests').doc();
      final imageUrl =
          imageFile != null ? await uploadImage() : existingImageUrl;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? <String, dynamic>{};

      final data = {
        'title': titleController.text.trim(),
        'guestCount': int.tryParse(guestController.text) ?? 0,
        'location': locationController.text.trim(),
        'date': dateController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': category,
        'imageUrl': imageUrl,
        'ownerId': user.uid,
        'ownerName': userData['name'] ?? 'Kullanici',
        'requestType': 'design',
        'status': 'open',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      };

      if (_isEditing) {
        await requestRef.update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final success = await CreditService().performAction(
          userId: user.uid,
          cost: 10,
          actionName: 'create_request',
          onSuccess: () async {
            await requestRef.set({
              ...data,
              'createdAt': FieldValue.serverTimestamp(),
              'expiresAt': buildPublicExpiryTimestamp(
                requestType: 'design',
              ),
            });
          },
        );

        if (!mounted) {
          return;
        }

        if (!success) {
          PaywallService.showInsufficientCreditsSheet(
            context,
            title: 'Organizasyon ilani vermek icin 10 kredi gerekiyor',
            message:
                'Organizasyon ilaninizi yayina almak icin once kredi satin alabilir, sonra tek dokunusla devam edebilirsiniz.',
            highlight: 'Organizasyon ilan paketleri',
          );
          return;
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Organizasyon ilanı güncellendi.'
                : 'Organizasyon ilanı yayına alındı.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Organizasyon İlanıni Duzenle' : 'Organizasyon İlanı',
        ),
      ),
      body: isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildChecklistCard(),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Organizasyon Basligi',
                      hintText: 'Orn: 30 kişilik butik nisan masasi ve backdrop tasarimi',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: category.isEmpty ? null : category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: guestController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kac Kisilik',
                      hintText: 'Orn: 25',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Mekan / Ilce',
                      hintText: 'Orn: Kadikoy, evde kurulum',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );

                      if (date != null) {
                        dateController.text =
                            '${date.day}.${date.month}.${date.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Detay',
                      hintText: 'Renk paleti, masa adedi, cicek istegi, backdrop olcusu, karsilama panosu gibi beklentilerini yaz.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewCard(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createRequest,
                      child: Text(
                        _isEditing
                            ? 'Degisiklikleri Kaydet'
                            : '10 Kredi ile Premium Ilan Ver',
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
          colors: [Color(0xFFFFF1ED), Color(0xFFFFDECF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium organizasyon ilani',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nasil bir kurgu istedigini ne kadar net anlatirsan, tasarimcilar da sana o kadar hızlı ve isabetli teklif gonderir.',
            style: TextStyle(height: 1.45),
          ),
          SizedBox(height: 10),
          Text(
            'Ilan yayina alma bedeli: 10 kredi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFB85C00),
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
        color: const Color(0xFFF8F6F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DDCF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daha iyi teklif icin bunlari ekle',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 10),
          _DesignChecklistItem(text: 'Etkinlik tipi ve genel stil'),
          _DesignChecklistItem(text: 'Kisi sayisi ve mekan bilgisi'),
          _DesignChecklistItem(text: 'Tarih ve kurulum zamani'),
          _DesignChecklistItem(text: 'Renk, cicek, masa veya pano beklentisi'),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageFile != null
            ? Image.file(imageFile!, fit: BoxFit.cover)
            : (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                ? Image.network(existingImageUrl!, fit: BoxFit.cover)
                : const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36),
                    SizedBox(height: 8),
                    Text('Ilham gorseli veya mekan fotosu ekle'),
                  ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final title = titleController.text.trim();
    final date = dateController.text.trim();
    final guest = guestController.text.trim();
    final location = locationController.text.trim();
    final detail = descriptionController.text.trim();
    final categoryLabel =
        category.isEmpty ? 'Kategori secilmedi' : (categories[category] ?? category);

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
          const Text(
            'Ilan ozeti',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title.isEmpty ? 'Baslik burada gorunecek.' : title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(categoryLabel),
          const SizedBox(height: 4),
          Text(guest.isEmpty ? 'Kisi sayisi girilmedi' : '$guest kişilik'),
          const SizedBox(height: 4),
          Text(location.isEmpty ? 'Mekan girilmedi' : location),
          const SizedBox(height: 4),
          Text(date.isEmpty ? 'Tarih secilmedi' : date),
          const SizedBox(height: 8),
          Text(
            detail.isEmpty
                ? 'Detay eklediginde tasarimcilar senden ne istendigini daha iyi anlayacak.'
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

class _DesignChecklistItem extends StatelessWidget {
  final String text;

  const _DesignChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFFB76A1B),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
