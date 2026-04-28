import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RequestDeleteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> deleteRequest(String requestId) async {
    try {
      final callable = _functions.httpsCallable('deleteRequest');
      await callable.call({'requestId': requestId});
      return;
    } on FirebaseFunctionsException catch (e) {
      if (e.code != 'not-found' && e.code != 'unavailable') {
        rethrow;
      }
    }

    await _db.collection('requests').doc(requestId).update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}
