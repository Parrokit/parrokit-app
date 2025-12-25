import 'package:flutter/cupertino.dart';

class ClipEditorModel {
  /// 메타데이터
  String type;
  String titleText;
  String workName;
  String workNameNative;
  String seasonText;
  String episodeText;
  String episodeTitle;
  int? durationMs;
  List<String> tags;

  /// 파일 데이터
  String? existingRelPath;
  int? existingDurationMs;

  /// 세그먼트 포맷 (mm:ss.mmm 포맷)
  List<SegmentInput> segments;

  ClipEditorModel({
    this.type = '',
    this.titleText = '',
    this.workName = '',
    this.workNameNative = '',
    this.seasonText = '',
    this.episodeText = '',
    this.episodeTitle = '',
    this.durationMs,
    this.existingRelPath,
    this.existingDurationMs,
    List<String>? tags,
    List<SegmentInput>? segments,
  })  : tags = tags ?? <String>[],
        segments = segments ?? <SegmentInput>[SegmentInput.empty()];
}

/// 세그먼트 입력 텍스트 필드 객체
class SegmentInput {
  final TextEditingController startCtl;
  final TextEditingController endCtl;
  final TextEditingController originalCtl;
  final TextEditingController pronCtl;
  final TextEditingController koCtl;

  SegmentInput({
    required this.startCtl,
    required this.endCtl,
    required this.originalCtl,
    required this.pronCtl,
    required this.koCtl,
  });

  factory SegmentInput.empty() => SegmentInput(
        startCtl: TextEditingController(),
        endCtl: TextEditingController(),
        originalCtl: TextEditingController(),
        pronCtl: TextEditingController(),
        koCtl: TextEditingController(),
      );

  void dispose() {
    startCtl.dispose();
    endCtl.dispose();
    originalCtl.dispose();
    pronCtl.dispose();
    koCtl.dispose();
  }
}
