/// [역할]
/// 클립의 메타데이터(제목, 재생 시간, 태그 목록)를 담는 불변 데이터 클래스.
///
/// UI에서 클립 정보를 간편하게 전달하거나 표시하기 위해 사용됩니다.
class ClipMeta {
  final String title;
  final int durationMs;
  final List<String> tags;

  ClipMeta({
    required this.title,
    required this.durationMs,
    required this.tags,
  });
}
