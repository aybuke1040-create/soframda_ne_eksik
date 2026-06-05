import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadDeliveryImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Authenticated user required for upload.');
    }

    final ref = _storage
        .ref()
        .child('delivery_images')
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
