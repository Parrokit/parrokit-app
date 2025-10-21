import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._internal();
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  InterstitialAd? _ad;
  bool _isLoading = false;

  /// ✅ 플랫폼별 광고 단위 ID
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      // 👉 Android용
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // 👉 iOS용
      return 'ca-app-pub-3940256099942544/1033173712'; // (테스트 ID 예시, 실제 값 넣기)
    } else {
      return ''; // 웹/기타 플랫폼
    }
  }

  /// 광고 로드
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
              loadAd(); // 닫히면 바로 다음 광고 준비
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
          // 실패 시 재시도 로직 넣어도 됨 (예: 타이머로 일정 시간 후 재로드)
        },
      ),
    );
  }

  /// 광고 보여주기
  void showAd() {
    if (_ad != null) {
      _ad!.show();
      _ad = null;
    } else {
      loadAd(); // 준비 안 됐으면 로드 시도
    }
  }
}