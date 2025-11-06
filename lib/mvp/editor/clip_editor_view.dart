import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:parrokit/mvp/editor/clip_editor_model.dart';

abstract class ClipEditorView{
  /// Presentr -> View를 위한 액세서
  BuildContext get context;

  /// controllers 값 접근
  String get clipTitle;
  String get workName;
  String get workNameNative;
  String get seasonText;
  String get episodeText;
  String get epiTitle;
  String get type;
  List<String> get tags;
  List<SegmentInput> get segments;
  int? get durationMsInput;
  PlatformFile? get pickedFile;

  /// UI 업데이트
  void setPicked(PlatformFile? f);
  void setThumb(Uint8List? bytes);
  void setDurationMs(int ms);
  void setSaving(bool saving);
  void showToastMsg(String msg);
  void refresh();
  Future<void> closeAfterSaved();
}