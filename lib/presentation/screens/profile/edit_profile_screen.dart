import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  File? imageFile;
  String? photoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = (data['name'] ?? '').toString();
      photoUrl = (data['photoUrl'] ?? '').toString();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null || !mounted) {
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: const Color(0xFFB97328),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFB97328),
          lockAspectRatio: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Kırp',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (cropped == null || !mounted) {
      return;
    }

    setState(() {
      imageFile = File(cropped.path);
    });
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) {
      return photoUrl;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      await ref.putFile(imageFile!);
      return await ref.getDownloadURL();
    } catch (_) {
      return photoUrl;
    }
  }

  Future<void> saveProfile() async {
    final trimmedName = nameController.text.trim();

    if (trimmedName.isEmpty) {
      await ActionFeedbackService.show(
        context,
        title: 'İsim gerekli',
        message: 'İsim boş olamaz.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newPhotoUrl = await uploadImage();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': trimmedName,
        'photoUrl': newPhotoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

      await FirebaseAuth.instance.currentUser?.updateDisplayName(trimmedName);

      if (!mounted) {
        return;
      }
      await ActionFeedbackService.show(
        context,
        title: 'Profil güncellendi',
        message: 'Profil güncellendi.',
        icon: Icons.check_circle_outline_rounded,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Profil güncellenemedi',
        message: 'Profil güncellenemedi: $e',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = imageFile != null
        ? FileImage(imageFile!)
        : (photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null) as ImageProvider<Object>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: const Color(0xFFF2EAE0),
                          backgroundImage: currentImage,
                          child: currentImage == null
                              ? const Icon(Icons.camera_alt, size: 30)
                              : null,
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB97328),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fotoğraf seçtikten sonra kırpıp kaydedebilirsin.',
                    style: TextStyle(color: Color(0xFF7C6D60)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Profil Adı',
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : saveProfile,
                      child: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
