import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> createChatRoom(
    String userA,
    String userB,
    String requestId,
  ) async {
    final users = [userA, userB]..sort();
    final chatId = "${users[0]}_${users[1]}_$requestId";

    final chatRef = _db.collection('chats').doc(chatId);

    await chatRef.set({
      'users': users,
      'participants': {
        userA: true,
        userB: true,
      },
      'requestId': requestId,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'names': {},
      'photos': {},
    }, SetOptions(merge: true));

    return chatId;
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  }) async {
    final callable = _functions.httpsCallable('sendMessage');
    await callable.call({
      'chatId': chatId,
      'text': text,
    }).timeout(const Duration(seconds: 15));
  }

  Future<void> resetUnread(String chatId) async {}
}
