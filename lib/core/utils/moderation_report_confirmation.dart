import 'package:flutter/material.dart';

Future<bool> confirmModerationReport(
  BuildContext context, {
  required String reason,
}) async {
  if (!context.mounted) return false;

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.flag_outlined),
          title: const Text('Şikâyeti gönder?'),
          content: Text(
            'Seçilen neden: $reason\n\n'
            'Bu işlem moderasyon ekibine inceleme bildirimi gönderir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Şikâyeti Gönder'),
            ),
          ],
        ),
      ) ??
      false;
}
