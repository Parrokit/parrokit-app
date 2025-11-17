// lib/provider/user_provider.dart

import 'package:flutter/foundation.dart';
import 'package:parrokit/data/models/user.dart';
import 'package:parrokit/services/auth_service.dart';

/// 앱 전역에서 사용하는 "현재 유저" 상태를 관리하는 Provider.
///
/// 역할:
/// - 앱 시작 시 로컬(UserPrefs)에서 유저를 복원하거나, 없으면 게스트 유저 생성
/// - 현재 유저(PaUser)와 코인 값을 UI에 노출
/// - 코인 증감, 로그아웃 등의 액션을 AuthService를 통해 위임
///
/// 현재는 외부 인증/서버 연동 없이 로컬 전용 동작만 하지만,
/// 나중에 Firebase/Auth 서버를 붙이더라도 이 클래스의 public API는
/// 최대한 그대로 유지하는 것을 목표로 합니다.
class UserProvider extends ChangeNotifier {
  final AuthService _authService;

  PaUser? _currentUser;
  bool _isLoading = false;

  UserProvider(this._authService);

  /// 현재 로그인된 유저(없을 수도 있음)
  PaUser? get currentUser => _currentUser;

  /// 유저 정보를 로딩 중인지 여부
  bool get isLoading => _isLoading;

  /// "로그인된 상태"라고 볼 수 있는지 여부
  bool get isLoggedIn => _currentUser != null;

  /// 현재 코인 수 (유저가 없으면 0)
  int get coins => _currentUser?.coins ?? 0;

  /// 앱 시작 시 혹은 필요한 시점에 호출해서
  /// - 저장된 유저를 불러오거나
  /// - 없으면 게스트 유저를 생성합니다.
  Future<void> init() async {
    _setLoading(true);

    try {
      final existing = await _authService.getCurrentUser();
      if (existing != null) {
        _currentUser = existing;
      } else {
        _currentUser = await _authService.signInAsGuest();
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 강제로 새 게스트 유저를 만들고 싶을 때 사용합니다.
  /// (대부분의 경우 [init] 만으로 충분합니다.)
  Future<void> signInAsGuest() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInAsGuest();
    } finally {
      _setLoading(false);
    }
  }

  /// 코인을 delta 만큼 증감시키고, 변경 사항을 UI에 반영합니다.
  /// - delta는 음수도 허용됩니다.
  Future<void> addCoins(int delta) async {
    if (_currentUser == null) return;

    final updated = await _authService.addCoins(delta);
    if (updated != null) {
      _currentUser = updated;
      notifyListeners();
    }
  }

  /// 유저 정보를 외부(서버, 프로필 편집 화면 등)에서 갱신했을 때 호출합니다.
  Future<void> updateUser(PaUser user) async {
    await _authService.saveUser(user);
    _currentUser = user;
    notifyListeners();
  }

  /// 로그아웃/초기화.
  /// 로컬 저장소를 비우고 메모리에 있는 유저도 제거합니다.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}