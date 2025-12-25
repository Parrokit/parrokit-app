// ============================================================================
// lib/features/_content/editor/data/services/time_code_service.dart
// ============================================================================
//
// [역할]
// 타임코드 변환 서비스.
// 밀리초 ↔ MM:SS.mmm 형식 변환.
//
// [레이어]
// Data Layer > Services
// ============================================================================

class TimecodeService {
  static final RegExp mmssmmm = RegExp(r'^\d{2}:\d{2}\.\d{3}$');

  String msToMMSSmmm(int ms) {
    final m = ms ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    final u = ms % 1000;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${u.toString().padLeft(3, '0')}';
  }

  int parseToMs(String normalized) {
    final m = RegExp(r'^(\d{2}):(\d{2})\.(\d{3})$').firstMatch(normalized)!;
    final mm = int.parse(m.group(1)!);
    final ss = int.parse(m.group(2)!);
    final ms = int.parse(m.group(3)!);
    return mm * 60000 + ss * 1000 + ms;
  }
}
