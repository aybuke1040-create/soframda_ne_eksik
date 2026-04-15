import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OfferService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<bool> sendOffer({
    required String requestId,
    required String ownerId,
    required int price,
    String actionName = 'send_offer',
    bool fromChat = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final senderId = user.uid;
    final offerId = "${requestId}_$senderId";
    final offerRef = _db.collection("offers").doc(offerId);
    final exists = await offerRef.get();

    if (exists.exists) {
      throw Exception("Bu ilana zaten teklif verdiniz");
    }

    final callable = _functions.httpsCallable('sendOffer');
    await callable.call({
      'requestId': requestId,
      'ownerId': ownerId,
      'price': price,
      'actionName': actionName,
      'fromChat': fromChat,
    });

    return true;
  }

  Future<String> acceptOffer({
    required String offerId,
    required String requestId,
  }) async {
    final callable = _functions.httpsCallable('acceptOffer');
    final result = await callable.call({
      'offerId': offerId,
      'requestId': requestId,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return data['chatId']?.toString() ?? '';
  }
}
