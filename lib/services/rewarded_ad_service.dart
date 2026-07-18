import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService._();

  static final RewardedAdService instance = RewardedAdService._();

  static const String _androidRewardedAdUnitId =
      'ca-app-pub-8020844869798583/1942997978';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-8020844869798583/8975310186';

  RewardedAd? _rewardedAd;
  Future<bool>? _loadFuture;

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

  Future<bool> preload() {
    if (_rewardedAd != null) return Future<bool>.value(true);
    return _loadFuture ??= _loadAd().whenComplete(() => _loadFuture = null);
  }

  Future<bool> _loadAd() async {
    final adUnitId = _adUnitId;
    if (adUnitId == null) return false;

    final completer = Completer<bool>();

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
  }

  Future<bool> showPreloadedAd({
    required String userId,
    required String sessionId,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) return false;

    _rewardedAd = null;
    ad.setServerSideOptions(
      ServerSideVerificationOptions(
        userId: userId,
        customData: sessionId,
      ),
    );
    final completer = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(preload());
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(preload());
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
}
