import 'package:cloud_firestore/cloud_firestore.dart';

const int kReadyFoodLifetimeDays = 2;
const int kDefaultRequestLifetimeDays = 7;
const Set<String> kInactiveRequestStatuses = {
  'completed',
  'deleted',
  'cancelled',
  'canceled',
  'closed',
  'expired',
};

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
  final status = (data['status'] ?? '').toString().toLowerCase().trim();

  if (kInactiveRequestStatuses.contains(status)) {
    return false;
  }

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

bool isRequestActiveForOffers(Map<String, dynamic>? data, {DateTime? now}) {
  if (data == null) {
    return false;
  }

  final status = (data['status'] ?? '').toString().toLowerCase().trim();
  if (kInactiveRequestStatuses.contains(status)) {
    return false;
  }

  return isRequestVisibleForPublic(data, now: now);
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
