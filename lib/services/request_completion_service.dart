import 'package:cloud_functions/cloud_functions.dart';

class RequestCompletionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> markCompleted({
    required String requestId,
    required String currentUserId,
    required bool isOwner,
  }) async {
    final callable = _functions.httpsCallable('markRequestCompleted');
    final result = await callable.call({
      'requestId': requestId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }
}
