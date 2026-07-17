import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-8020844869798583/1942997978';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-8020844869798583/8975310186';

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isReady => _rewardedAd != null;

  String? get _adUnitId {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidRewardedAdUnitId;
      case TargetPlatform.iOS:
        return _iosRewardedAdUnitId;
      default:
        return null;
    }
  }

  Future<bool> preload({
    required String userId,
    required String sessionId,
  }) async {
    if (_rewardedAd != null) return true;
    if (_isLoading) return false;

    final adUnitId = _adUnitId;
    if (adUnitId == null) return false;

    _isLoading = true;
    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.setServerSideOptions(
            ServerSideVerificationOptions(
              userId: userId,
              customData: sessionId,
            ),
          );
          _rewardedAd = ad;
          _isLoading = false;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _isLoading = false;
        return false;
      },
    );
  }

  Future<bool> showPreloadedAd() async {
    final ad = _rewardedAd;
    if (ad == null) return false;

    _rewardedAd = null;
    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(
      onUserEarnedReward: (_, __) {
        rewardEarned = true;
      },
    );

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        ad.dispose();
        return false;
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
