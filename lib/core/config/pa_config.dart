import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaConfig {
  /// 플레이어
  static bool segmentLoop = false; // 구간 재생
  static bool repeatAll = false; // 반복 재생(전체)
  static bool showSubtitles = true; // 자막 표시(플레이어)
  static double defaultPlaybackRate = 1.0; // 기본 재생 속도

  /// 쇼츠
  static bool autoNext = true; // 자동 넘기기
  static bool shortsShowSubtitles = true; // 자막 표시(쇼츠)

  /// 앱 테마는 프로바이더 관리

  static Future<void> loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();

    segmentLoop = p.getBool('segmentLoop') ?? false;
    repeatAll = p.getBool('repeatAll') ?? false;
    showSubtitles = p.getBool('showSubtitles') ?? true;
    defaultPlaybackRate = p.getDouble('defaultPlaybackRate') ?? 1.0;

    autoNext = p.getBool('autoNext') ?? true;
    shortsShowSubtitles = p.getBool('shortsShowSubtitles') ?? true;
  }

  static Future<void> saveToPrefs() async {
    final p = await SharedPreferences.getInstance();

    await p.setBool('segmentLoop', segmentLoop);
    await p.setBool('repeatAll', repeatAll);
    await p.setBool('showSubtitles', showSubtitles);
    await p.setDouble('defaultPlaybackRate', defaultPlaybackRate);

    await p.setBool('autoNext', autoNext);
    await p.setBool('shortsShowSubtitles', shortsShowSubtitles);
  }
}
