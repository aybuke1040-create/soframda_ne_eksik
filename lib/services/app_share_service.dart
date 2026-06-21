import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

enum AppShareStatus {
  success,
  dismissed,
  unavailable,
}

class AppShareService {
  const AppShareService();

  Future<AppShareStatus> shareText(
    BuildContext context, {
    required String message,
    String? subject,
  }) async {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox != null && renderBox.hasSize
          ? renderBox.localToGlobal(Offset.zero) & renderBox.size
          : const Rect.fromLTWH(0, 0, 1, 1);

      final result = await Share.share(
        message,
        subject: subject,
        sharePositionOrigin: origin,
      );

      switch (result.status) {
        case ShareResultStatus.success:
          return AppShareStatus.success;
        case ShareResultStatus.dismissed:
          return AppShareStatus.dismissed;
        case ShareResultStatus.unavailable:
          return AppShareStatus.unavailable;
      }
    } catch (_) {
      return AppShareStatus.unavailable;
    }
  }
}
