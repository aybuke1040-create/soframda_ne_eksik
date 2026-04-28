import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soframda_ne_eksik/core/utils/content_moderation_utils.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() {
      _imageFile = File(picked.path);
    });
  }

  Future<String?> _uploadImage(String recipeId) async {
    if (_imageFile == null) {
      return null;
    }

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipes')
          .child('$recipeId.jpg');

      await ref.putFile(_imageFile!);
      return ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveRecipe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      await ActionFeedbackService.show(
        context,
        title: 'Başlık gerekli',
        message: 'Tarif başlığı gir.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    final moderationIssue = findObjectionableContent({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'ingredients': _ingredientsController.text,
      'instructions': _instructionsController.text,
    });
    if (moderationIssue != null) {
      await ActionFeedbackService.show(
        context,
        title: 'Icerik gonderilemedi',
        message:
            'Topluluk kurallarina aykiri gorunen bir ifade tespit edildi. Lutfen tarifi duzeltip tekrar deneyin.',
        icon: Icons.report_gmailerrorred_rounded,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final rawOwnerName = (userData['name'] as String? ?? '').trim();
      final ownerName = rawOwnerName.isNotEmpty ? rawOwnerName : 'Kullanici';

      final recipeRef = FirebaseFirestore.instance.collection('requests').doc();
      final imageUrl = await _uploadImage(recipeRef.id);

      await recipeRef.set({
        'id': recipeRef.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients': _ingredientsController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'ownerId': user.uid,
        'ownerName': ownerName,
        'userName': ownerName,
        'type': 'recipe',
        'requestType': 'recipe',
        'status': 'published',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      if (_imageFile != null && imageUrl == null) {
        await ActionFeedbackService.show(
          context,
          title: 'Tarif kaydedildi',
          message: 'Tarif kaydedildi, görsel yüklenemedi.',
          icon: Icons.info_outline_rounded,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      await ActionFeedbackService.show(
        context,
        title: 'Tarif kaydedilemedi',
        message: 'Tarif kaydedilemedi: $e',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarif Ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 40),
                        SizedBox(height: 8),
                        Text('Tarif görseli ekle'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tarif Adı',
              hintText: 'Örn: El açması su böreği',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Kısa Açıklama',
              hintText: 'Bu tarifi neden seviyorsun, ne zaman yapılır?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ingredientsController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Malzemeler',
              hintText: 'Malzemeleri satır satır yazabilirsin',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Yapılış',
              hintText: 'Adımları sırayla anlat',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveRecipe,
            child: Text(_isSaving ? 'Kaydediliyor...' : 'Tarifi Yayınla'),
          ),
        ],
      ),
    );
  }
}



