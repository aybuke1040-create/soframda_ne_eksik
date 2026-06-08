import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String latestVersion;
  final String minimumVersion;
  final String storeUrl;
  final String title;
  final String message;
  final bool isRequired;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.storeUrl,
    required this.title,
    required this.message,
    required this.isRequired,
  });
}

class AppUpdateService {
  Future<AppUpdateInfo?> getUpdateInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final doc = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('client')
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    if (data == null) {
      return null;
    }

    final isAndroid = Platform.isAndroid;
    final latestVersion =
        (isAndroid ? data['androidLatestVersion'] : data['iosLatestVersion'])
                ?.toString()
                .trim() ??
            '';
    final minimumVersion =
        (isAndroid ? data['androidMinVersion'] : data['iosMinVersion'])
                ?.toString()
                .trim() ??
            '';
    final storeUrl = (isAndroid ? data['androidStoreUrl'] : data['iosStoreUrl'])
            ?.toString()
            .trim() ??
        '';

    if (latestVersion.isEmpty || storeUrl.isEmpty) {
      return null;
    }

    final needsSoftUpdate = _compareVersions(currentVersion, latestVersion) < 0;
    final needsHardUpdate = minimumVersion.isNotEmpty &&
        _compareVersions(currentVersion, minimumVersion) < 0;

    if (!needsSoftUpdate && !needsHardUpdate) {
      return null;
    }

    final title = (data['updateTitle']?.toString().trim().isNotEmpty ?? false)
        ? data['updateTitle'].toString().trim()
        : 'Güncelleme var';
    final message = (data['updateMessage']?.toString().trim().isNotEmpty ??
            false)
        ? data['updateMessage'].toString().trim()
        : 'Uygulamanın yeni bir sürümü yayınlandı. En iyi deneyim için lütfen güncelle.';

    return AppUpdateInfo(
      latestVersion: latestVersion,
      minimumVersion: minimumVersion,
      storeUrl: storeUrl,
      title: title,
      message: message,
      isRequired: needsHardUpdate,
    );
  }

  Future<void> showUpdateDialog(
    BuildContext context,
    AppUpdateInfo info,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.isRequired,
      builder: (dialogContext) {
        return PopScope(
          canPop: !info.isRequired,
          child: AlertDialog(
            title: Text(info.title),
            content: Text(info.message),
            actions: [
              if (!info.isRequired)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Daha sonra'),
                ),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.tryParse(info.storeUrl);
                  if (uri != null) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }

                  if (!info.isRequired && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Güncelle'),
              ),
            ],
          ),
        );
      },
    );
  }

  int _compareVersions(String current, String target) {
    final currentParts = current.split('.').map(_toInt).toList();
    final targetParts = target.split('.').map(_toInt).toList();
    final maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;

    for (var i = 0; i < maxLength; i++) {
      final currentValue = i < currentParts.length ? currentParts[i] : 0;
      final targetValue = i < targetParts.length ? targetParts[i] : 0;
      if (currentValue != targetValue) {
        return currentValue.compareTo(targetValue);
      }
    }

    return 0;
  }

  int _toInt(String value) => int.tryParse(value) ?? 0;
}
