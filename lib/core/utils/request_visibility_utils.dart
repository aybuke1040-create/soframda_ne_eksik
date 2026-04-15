import 'package:cloud_firestore/cloud_firestore.dart';

const int kReadyFoodLifetimeDays = 2;
const int kDefaultRequestLifetimeDays = 7;

int getPublicRequestLifetimeDays(Map<String, dynamic> data) {
  final requestType = (data['requestType'] ?? data['type'] ?? '').toString();
  final isReady = data['isReady'] == true;

  if (requestType == 'ready_food' || isReady) {
    return kReadyFoodLifetimeDays;
  }

  return kDefaultRequestLifetimeDays;
}

bool isRequestVisibleForPublic(Map<String, dynamic> data, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();

  final expiresAt = data['expiresAt'];
  if (expiresAt is Timestamp) {
    return !expiresAt.toDate().isBefore(currentTime);
  }

  final createdAt = data['createdAt'];
  if (createdAt is Timestamp) {
    final lifetimeDays = getPublicRequestLifetimeDays(data);
    final expiresOn = createdAt.toDate().add(
          Duration(days: lifetimeDays),
        );
    return !expiresOn.isBefore(currentTime);
  }

  return true;
}

Timestamp buildPublicExpiryTimestamp({
  String requestType = '',
  bool isReady = false,
}) {
  final lifetimeDays =
      requestType == 'ready_food' || isReady
          ? kReadyFoodLifetimeDays
          : kDefaultRequestLifetimeDays;

  return Timestamp.fromDate(
    DateTime.now().add(
      Duration(days: lifetimeDays),
    ),
  );
}
