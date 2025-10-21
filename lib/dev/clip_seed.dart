// lib/seed/clip_seed.dart
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:parrokit/data/local/pa_database.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../provider/media_provider.dart';

// ---------------------------
// 1) 하드코딩 메타데이터
// ---------------------------
class _SeedSeg {
  final String start; // "mm:ss:mmm" 또는 "mm:ss.mmm"
  final String end;
  final String original;
  final String pron;
  final String trans;
  const _SeedSeg(this.start, this.end, this.original, this.pron, this.trans);
}

class _SeedClip {
  final String titleName;      // 작품명 (ko)
  final String titleNameNative;         // 작품명 (ja)  ← 추가
  final String clipTitle;      // 클립 제목
  final String type;           // 'season' | 'movie'
  final int? seasonNumber;     // 시즌 번호
  final int? episodeNumber;    // 화 번호
  final String episodeTitle;   // 회차 제목
  final List<String> tags;     // 태그 문자열들
  final List<_SeedSeg> segs;   // 구간들
  const _SeedClip({
    required this.titleName,
    required this.titleNameNative,
    required this.clipTitle,
    required this.type,
    this.seasonNumber,
    this.episodeNumber,
    required this.episodeTitle,
    required this.tags,
    required this.segs,
  });
}

final List<_SeedClip> _seedClips = [
  _SeedClip(
    titleName: '히카루가 죽은 여름',
    titleNameNative: 'ヒカルが死んだ夏',
    clipTitle: '너와 함께 할게',
    type: 'season',
    seasonNumber: 1,
    episodeNumber: 8,
    episodeTitle: '접촉',
    tags: ['히카루', '죽음', '여름', '미스터리', '2025'],
    segs: [
      _SeedSeg('00:01:100', '00:05:200', 'これから先お前がまた誰か殺してまったとしても',
          '코레카라 사키 오마에가 마타 다레카 코로시테맛타토 시테모', '앞으로 네가 또 누군가를 죽인다 해도'),
      _SeedSeg('00:06:300', '00:08:500', '俺も一緒に罪を背負う',
          '오레모 잇쇼니 츠미오 세오우', '나도 함께 그 죄를 짊어지겠다'),
    ],
  ),
  _SeedClip(
    titleName: '히카루가 죽은 여름',
    titleNameNative: 'ヒカルが死んだ夏',
    clipTitle: '친구와 헤어질 때',
    type: 'season',
    seasonNumber: 1,
    episodeNumber: 4,
    episodeTitle: '여름 축제',
    tags: ['인사', '헤어짐', '일본어 공부'],
    segs: [
      _SeedSeg('00:02:100', '00:05:000', 'ってかもうそろそろ帰らんとやわ',
          '텟카 모오 소로소로 카에란토 야와', '아무튼 이제 슬슬 가야겠다'),
      _SeedSeg('00:05:500', '00:07:150', 'おっ また明日',
          '옷 마타 아시타', '그래, 내일 봐'),
    ],
  ),
  _SeedClip(
    titleName: '히카루가 죽은 여름',
    titleNameNative: 'ヒカルが死んだ夏',
    clipTitle: '본인만의 줏대',
    type: 'season',
    seasonNumber: 1,
    episodeNumber: 4,
    episodeTitle: '여름 축제',
    tags: ['회사', '퇴근', '일하기 싫다'],
    segs: [
      _SeedSeg('00:00:250', '00:02:000', 'こういうやり方してんすよ',
          '코우이우 야리카타 시텐스요', '저는 영감 같은 게 없어서 이런 식으로 일해요'),
      _SeedSeg('00:02:500', '00:05:200', '会社の推奨するやり方は嫌いですし',
          '카이샤노 스이쇼우스루 야리카타와 키라이데스시', '회사에서 권장하는 방식이 싫어서요'),
    ],
  ),
  _SeedClip(
    titleName: '단다단',
    titleNameNative: 'ダンダダン',
    clipTitle: '알콩달콩',
    type: 'season',
    seasonNumber: 1,
    episodeNumber: 1,
    episodeTitle: '그게 바로 사랑의 시작이잖아',
    tags: ['오카룽', '모모', '유령', '사랑'],
    segs: [
      _SeedSeg('00:00:000', '00:02:150', 'よくもさっき偉そうに言えましたね',
          '요쿠모 삿키 에라소오니 이에마시타네', '그래 놓고 나한테 그렇게 훈계를 한 거예요?'),
      _SeedSeg('00:02:150', '00:03:410', '恐縮っす',
          '쿄오슈쿠쓰', '아이고 미안해라'),
      _SeedSeg('00:03:410', '00:05:510', 'さっきまでの態度を返せ！',
          '삿키마데노 타이도오 카에세!', '당당하게 굴던 거 사과해요!'),
      _SeedSeg('00:05:200', '00:08:510', '幽霊見たことないのに信じてるっておかしいでしょ！',
          '유우레이 미타코토 나이노니 신지테루떼 오카시이데쇼!', '본 적도 없는데 어떻게 유령을 믿는 거죠?'),
      _SeedSeg('00:08:900', '00:10:150', 'おかしくねぇわ',
          '오카시쿠네에와', '그게 뭐 어때서'),
    ],
  ),
  _SeedClip(
    titleName: '단다단',
    titleNameNative: 'ダンダダン',
    clipTitle: '드디어 조용하네',
    type: 'season',
    seasonNumber: 2,
    episodeNumber: 9,
    episodeTitle: '집을 다시 짓고 싶어',
    tags: ['평화'],
    segs: [
      _SeedSeg('00:02:000', '00:04:500', 'あ～あ 静かになっちゃった',
          '아~아 시즈카니 낫챳타', '아, 이제 조용하네'),
    ],
  ),
  _SeedClip(
    titleName: '장송의 프리렌',
    titleNameNative: '葬送のフリーレン',
    clipTitle: '대머리 ㅠㅠ',
    type: 'season',
    seasonNumber: 1,
    episodeNumber: 1,
    episodeTitle: '모험의 끝',
    tags: ['탈모', '대머리', '슬픔'],
    segs: [
      _SeedSeg('00:00:500', '00:03:350', 'ハゲなんだからこだわったって意味ないよ',
          '하게난다카라 코다왓탓테 이미나이요', '대머리니까 꾸며도 의미 없어'),
    ],
  ),
];

// ---------------------------
// 2) 공개: 시드 실행 함수 (tmp 저장소 사용)
// ---------------------------
Future<bool> runSeedFromFilePickerTmp(BuildContext context) async {
  try {
    // 1) 파일 6개 선택
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
      allowMultiple: true,
    );
    if (pick == null || pick.files.length != _seedClips.length) return false;

    // 🔑 파일 이름 숫자 추출 → 정렬 (예: Timeline 1 → 1)
    final files = [...pick.files]..sort((a, b) {
      final re = RegExp(r'(\d+)');
      final na = int.tryParse(re.firstMatch(a.name)?.group(1) ?? '') ?? 0;
      final nb = int.tryParse(re.firstMatch(b.name)?.group(1) ?? '') ?? 0;
      return na.compareTo(nb);
    });

    // 2) tmp/videos 로 복사 → 상대/절대경로 확보
    final copies = <_CopyResult>[];
    for (final f in files) {
      final p = f.path;
      if (p == null) return false;
      copies.add(await _copyToStorage(p));
    }

    // 3) 각 파일 duration(ms) 프로빙
    final durations = <int>[];
    for (final c in copies) {
      durations.add(await _probeDurationMs(c.abs));
    }

    // 4) addMedia: i번째 시드 ← i번째 파일
    final mp = context.read<MediaProvider>();
    for (int i = 0; i < _seedClips.length; i++) {
      final sc = _seedClips[i];
      final segs = sc.segs
          .map((s) => Segment(
        id: 0,
        clipId: 0,
        startMs: _parseToMs(s.start),
        endMs: _parseToMs(s.end),
        original: s.original,
        pron: s.pron,
        trans: s.trans,
      ))
          .toList()
        ..sort((a, b) => a.startMs.compareTo(b.startMs));

      await mp.addMedia(
        titleName: sc.titleName,
        titleNameNative: sc.titleNameNative,              // ← 일본어 이름 전달
        type: sc.type,
        seasonNumber: sc.type == 'season' ? sc.seasonNumber : null,
        episodeNumber: sc.type == 'season' ? sc.episodeNumber : null,
        episodeTitle: sc.episodeTitle,
        clipTitle: sc.clipTitle,
        filePath: copies[i].rel,        // DB에는 상대경로 저장
        durationMs: durations[i],       // ← 실제 길이(ms) 저장
        segments: segs,
        tags: sc.tags,
      );
    }
    return true;
  } catch (_) {
    return false;
  }
}

// ---------------------------
// 3) 유틸 (tmp/videos 복사, 시간 파싱, 길이 프로빙)
// ---------------------------
class _CopyResult {
  final String rel; // 예: videos/clip_12345.mp4
  final String abs; // 예: /var/.../Documents/videos/clip_12345.mp4
  const _CopyResult(this.rel, this.abs);
}

Future<_CopyResult> _copyToStorage(String absPath) async {
  final tmp = await getApplicationDocumentsDirectory();
  final dir = Directory('${tmp.path}/videos');
  if (!await dir.exists()) await dir.create(recursive: true);

  final src = File(absPath);
  final ext = _ext(absPath);
  final unique = 'clip_${DateTime.now().microsecondsSinceEpoch}$ext';
  final dst = File('${dir.path}/$unique');

  await src.copy(dst.path);
  return _CopyResult('videos/$unique', dst.path);
}

String _ext(String p) {
  final i = p.lastIndexOf('.');
  return i >= 0 ? p.substring(i) : '';
}

int _parseToMs(String t) {
  final m = RegExp(r'^(\d{2}):(\d{2})[:\.](\d{3})$').firstMatch(t.trim());
  if (m == null) throw FormatException('시각 형식 오류: $t (예: 00:05:123)');
  final mm = int.parse(m.group(1)!);
  final ss = int.parse(m.group(2)!);
  final ms = int.parse(m.group(3)!);
  return (mm * 60 + ss) * 1000 + ms;
}

Future<int> _probeDurationMs(String absPath) async {
  final controller = VideoPlayerController.file(File(absPath));
  await controller.initialize();
  final ms = controller.value.duration.inMilliseconds;
  await controller.dispose();
  return ms;
}