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
