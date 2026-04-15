import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPush(
  String token,
  String title,
  String body,
  String type,
  String? requestId,
) async {
  const serverKey = "BURAYA_FIREBASE_SERVER_KEY";

  await http.post(
    Uri.parse("https://fcm.googleapis.com/fcm/send"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=$serverKey",
    },
    body: jsonEncode({
      "to": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": type,
        "requestId": requestId,
      }
    }),
  );
}
