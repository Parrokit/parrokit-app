// ============================================================================
// lib/core/services/device_id_service.dart
// ============================================================================
//
// [역할]
// 기기 고유 식별자를 반환합니다.
// iOS: identifierForVendor (IDFV), Android: androidInfo.id
// 취득 실패 시 SharedPreferences에 생성·저장한 UUID로 폴백합니다.
//
// [레이어]
// Core Layer > Services
// ============================================================================

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const _prefKey = 'device_id_fallback';
  static String? _cached;

  static Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;

    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        final idfv = info.identifierForVendor;
        if (idfv != null && idfv.isNotEmpty) {
          _cached = idfv;
          return _cached!;
        }
      } else if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        final id = info.id;
        if (id.isNotEmpty) {
          _cached = id;
          return _cached!;
        }
      }
    } catch (_) {}

    // 폴백: SharedPreferences에 UUID 생성·저장
    final prefs = await SharedPreferences.getInstance();
    var fallback = prefs.getString(_prefKey);
    if (fallback == null) {
      fallback = const Uuid().v4();
      await prefs.setString(_prefKey, fallback);
    }
    _cached = fallback;
    return _cached!;
  }
}
