import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadDeliveryImage(File file) async {
    final ref = _storage
        .ref()
        .child('delivery_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
