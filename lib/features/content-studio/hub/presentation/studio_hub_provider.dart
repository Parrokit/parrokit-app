import 'package:flutter/material.dart';

class StudioHubProvider extends ChangeNotifier {
  String? _pendingCaptionFilePath;
  String? get pendingCaptionFilePath => _pendingCaptionFilePath;

  int? _requestedTabIndex;
  int? get requestedTabIndex => _requestedTabIndex;

  void sendAudioToCaptioning(String filePath) {
    _pendingCaptionFilePath = filePath;
    _requestedTabIndex = 0; // 자막 화면 탭
    notifyListeners();
  }

  void consumePendingCaptionFile(Function(String) onConsume) {
    if (_pendingCaptionFilePath != null) {
      onConsume(_pendingCaptionFilePath!);
      _pendingCaptionFilePath = null;
    }
  }

  void clearRequestedTabIndex() {
    if (_requestedTabIndex != null) {
      _requestedTabIndex = null;
    }
  }
}
