import 'dart:async';
// dart:io Platform not used currently
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapProvider extends ChangeNotifier {
  // 🔁 App Store Connect / Play Console에 등록한 Product ID와 반드시 동일
  static const String kRemoveAdsId = 'com.bull.parrokit.remove_ads';
  static const String _prefsKeyPremium = 'is_premium';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool available = false; // 스토어 가용 여부
  bool isPremium = false; // 프리미엄 소유 상태
  bool loading = true; // 초기 로딩/쿼리 중
  bool purchasing = false; // 결제 진행중 (버튼 디스에이블 등)
  List<ProductDetails> products = const [];

  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _inited = false;

  /// UI에서 쓰기 좋은 가격 문자열 (예: $0.99). 없으면 null
  String? get removeAdsPrice => removeAdsProduct?.price;

  ProductDetails? get removeAdsProduct =>
      products.where((p) => p.id == kRemoveAdsId).firstOrNull;

  Future<void> init() async {
    if (_inited) return; // 중복 초기화 방지

    _inited = true;

    loading = true;
    notifyListeners();
    // 1) 스토어 연결
    available = await _iap.isAvailable();

    // 2) 로컬 보유 플래그
    final prefs = await SharedPreferences.getInstance();
    isPremium = prefs.getBool(_prefsKeyPremium) ?? false;

    // 3) 상품 조회
    if (available) {
      final response = await _iap.queryProductDetails({kRemoveAdsId});
      if (response.error != null) {
        debugPrint('[IAP] queryProductDetails error: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[IAP] notFoundIDs: ${response.notFoundIDs} '
            '(Product ID가 콘솔과 다르거나, 아직 전파/승인 전일 수 있음)');
      }
      products = response.productDetails;
    }

    // 4) 구매 스트림 구독 (한 번만)
    _sub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _sub?.cancel(),
      onError: (e, st) {
        debugPrint('[IAP] purchaseStream error: $e');
        purchasing = false;
        notifyListeners();
      },
    );

    loading = false;
    notifyListeners();
  }

  Future<void> buyRemoveAds() async {
    if (!available) {
      debugPrint('[IAP] Store not available');
      return;
    }
    if (purchasing) return; // 중복 클릭 방지

    final pd = removeAdsProduct;
    if (pd == null) {
      debugPrint('[IAP] Product not loaded: $kRemoveAdsId');
      return;
    }

    purchasing = true;
    notifyListeners();

    final purchaseParam = PurchaseParam(productDetails: pd);
    // 광고 제거는 Non-Consumable
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (!available) return;
    purchasing = true;
    notifyListeners();

    await _iap.restorePurchases();
    // 결과는 _onPurchaseUpdated로 들어옴
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> detailsList) async {
    for (final pd in detailsList) {
      debugPrint('[IAP] update: id=${pd.productID}, status=${pd.status}');

      switch (pd.status) {
        case PurchaseStatus.pending:
          purchasing = true;
          notifyListeners();
          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] purchase error: ${pd.error}');
          purchasing = false;
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          purchasing = false;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // TODO: 프로덕션에서는 서버 영수증 검증 권장(특히 Android)
          if (pd.productID == kRemoveAdsId) {
            await _grantPremium();
          }
          if (pd.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(pd);
            } catch (e) {
              debugPrint('[IAP] completePurchase error: $e');
            }
          }
          purchasing = false;
          notifyListeners();
          break;
      }
    }
  }

  Future<void> _grantPremium() async {
    isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyPremium, true);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
