import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._internal();
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  // ─────────────────────────────────────────────────────────────────
  // 전면 광고 (Interstitial)
  // ─────────────────────────────────────────────────────────────────

  InterstitialAd? _ad;
  bool _isLoading = false;

  String get _interstitialAdUnitId {
    if (kReleaseMode) {
      if (Platform.isAndroid) return 'ca-app-pub-6519817120789589/3864454628';
      if (Platform.isIOS) return 'ca-app-pub-6519817120789589/8988581964';
    }
    // 테스트 ID
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1033173712';
    return '';
  }

  void loadAd() {
    if (_isLoading || _ad != null || _interstitialAdUnitId.isEmpty) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  void showAd() {
    if (_ad != null) {
      _ad!.show();
      _ad = null;
    } else {
      loadAd();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 보상형 광고 (Rewarded) — 시청 시 코인 지급
  // ─────────────────────────────────────────────────────────────────

  static const int rewardCoins = 5; // 광고 1회당 지급 코인

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  String get _rewardedAdUnitId {
    if (kReleaseMode) {
      if (Platform.isAndroid) return ''; // 실제 Android rewarded ID
      if (Platform.isIOS) return ''; // 실제 iOS rewarded ID
      return '';
    }
    // 테스트 ID
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    return '';
  }

  /// 보상형 광고를 미리 로드합니다.
  void loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null || _rewardedAdUnitId.isEmpty)
      return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// 보상형 광고를 보여줍니다.
  ///
  /// [onRewarded]: 시청 완료 시 지급 코인 수로 호출됩니다.
  /// 광고가 준비되지 않았으면 [onRewarded](-1)로 알립니다.
  void showRewardedAd({required void Function(int coins) onRewarded}) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      onRewarded(-1); // 준비 안 됨
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(rewardCoins);
      },
    );
    _rewardedAd = null;
  }

  bool get isRewardedAdReady => _rewardedAd != null;
}
