# Parrokit — 동영상 클립 기반 언어 쉐도잉 학습 앱

> **동영상 클립과 자막 세그먼트를 활용한 반복 학습 Flutter 앱**
> Flutter · Dart · MVVM + Clean Architecture · Provider · Drift (SQLite) · Firebase · OpenAI API · FFmpeg · just_audio / audio_service · GoRouter
> 개발 기간: 2025년 9월 ~ 2026년 9월 / 개인 프로젝트

---

## 1. 도입 배경

### 문제 인식

일본어를 비롯한 외국어를 학습할 때, 좋아하는 애니메이션의 특정 장면을 반복해서 듣는 "쉐도잉" 학습법이 효과적이라는 것은 잘 알려져 있습니다. 하지만 기존의 쉐도잉 도구들은 영상의 특정 구간을 정밀하게 잘라 반복 재생하기 어렵고, 자막(원문/발음/번역)을 세그먼트 단위로 구조화해서 관리하는 기능이 부족했습니다.

이 프로젝트는 **사용자가 직접 영상에서 원하는 장면을 클립으로 저장하고, 자막 세그먼트와 함께 반복 학습할 수 있는 모바일 앱**을 구축하는 것을 목표로 했습니다. 핵심은 단순한 영상 플레이어가 아니라, 클립 → 세그먼트 → 자막의 구조화된 학습 데이터를 사용자가 직접 만들고 관리할 수 있는 에디터를 제공하는 것이었습니다.

### 프로젝트 목표

- 영상 파일에서 **클립을 생성하고 자막 세그먼트(원문/발음/번역)를 구조화**하여 저장
- **세그먼트 단위 구간 반복, 배속 조절, 백그라운드 오디오** 등 학습에 최적화된 플레이어 제공
- **TikTok/Reels 스타일의 쇼츠** 기능으로 짧은 클립을 스와이프하며 부담 없이 학습
- OpenAI API를 활용한 **AI 기반 자동 자막 생성(STT + LLM 번역)** 으로 클립 제작 효율화
- 작품 → 시즌 → 에피소드 → 클립의 **4단계 계층 구조**로 대량의 클립을 체계적으로 관리

---

## 2. 기술적 문제 해결 과정

### 문제 1 — ViewModel 비대화: 600줄이 넘는 에디터 ViewModel을 어떻게 분리할 것인가

**상황**
클립 에디터 ViewModel(`ClipEditorViewModel`)은 파일 선택, 세그먼트 관리, 태그 관리, 자동완성, 메타데이터 입력 등 다양한 책임을 가지고 있었습니다. 모든 로직이 하나의 `ChangeNotifier` 클래스에 담기면서 600줄이 넘어갔고, 각 관심사의 경계가 불분명해져 유지보수가 어려워졌습니다.

**해결**
Dart의 **mixin**을 활용하여 관심사별로 로직을 물리적으로 분리했습니다.

```dart
// 메인 ViewModel은 mixin을 조합하여 구성
class ClipEditorViewModel extends ChangeNotifier
    with EditorFileMixin, EditorSegmentMixin, EditorTagMixin, EditorAutocompleteMixin {
  // 공통 의존성과 초기화 로직만 담당
}
```

각 mixin은 자신이 필요한 상태와 의존성을 abstract getter로 선언하고, 메인 ViewModel에서 이를 구현합니다.

```dart
// EditorFileMixin — 파일 선택/제거 로직만 담당
mixin EditorFileMixin on ChangeNotifier {
  FileStagingService get staging;        // abstract: 메인에서 구현
  ExtractThumbnailUseCase get extractThumb;

  PlatformFile? _picked;
  Uint8List? _thumb;

  Future<void> pickFromSandbox() async { ... }
  Future<void> pickFromPhotos() async { ... }
  void removePicked() { ... }
}
```

이 패턴은 클립 플레이어에도 동일하게 적용했습니다. `ClipPlayerViewModel`은 `PlaybackControlMixin`(재생/세그먼트 탐색), `AudioModeMixin`(백그라운드 오디오), `UiControlMixin`(풀스크린/오버레이)으로 분리됩니다.

핵심은 mixin이 `ChangeNotifier`를 `on` 제약으로 요구하므로, 각 mixin이 독립적으로 `notifyListeners()`를 호출할 수 있다는 점입니다. 상속 대신 수평적 조합을 사용하여 다이아몬드 상속 문제 없이 책임을 분리했습니다.

---

### 문제 2 — 쇼츠 무한 스크롤에서의 메모리 누적 문제

**상황**
TikTok/Reels 스타일의 세로 스와이프 UI를 `PageView.builder`로 구현했습니다. 사용자가 계속 스와이프할 때마다 `loadMore()`로 새 클립을 추가하는 방식이었는데, 장시간 사용 시 리스트에 클립 데이터(+ 비디오 플레이어 인스턴스)가 계속 누적되어 메모리가 증가하는 문제가 있었습니다.

**해결**
**Cycle Refresh** 패턴을 도입했습니다. 배치 크기(10개)를 단위로, 현재 배치의 마지막 인덱스를 넘어가면 이전 배치를 제거하고 인덱스를 리셋합니다.

```dart
const batchSize = ShortsProvider.pageSize; // 10
if (i >= batchSize) {
  // (1) 앞의 10개 삭제
  shorts.removeItems(batchSize);

  // (2) 화면 즉시 점프 (i=10 → 0)
  final newIndex = i - batchSize;
  _pageController.jumpToPage(newIndex);

  // (3) 상태 업데이트
  setState(() => _currentIndex = newIndex);
}
```

상단의 스토리형 ProgressBar도 `_currentIndex % pageSize`로 표시하여, 항상 0~9 범위에서 순환하도록 했습니다. 사용자 관점에서는 무한 스크롤이지만, 실제 메모리에는 최대 20개(현재 배치 + 다음 배치)의 클립만 유지됩니다.

---

### 문제 3 — 비디오 → 오디오 모드 전환 시 재생 위치 동기화

**상황**
플레이어에서 "백그라운드 오디오 모드"를 도입했습니다. 사용자가 비디오를 보다가 오디오 모드로 전환하면, 비디오 플레이어(`video_player`)를 멈추고 `just_audio` + `audio_service`로 동일한 파일의 오디오를 재생하는 구조입니다. 문제는 **두 개의 독립된 미디어 엔진 사이에서 재생 위치를 정확히 동기화**하는 것이었습니다. 오디오 모드 진입 시 비디오의 현재 위치를 가져오고, 탈출 시 오디오의 현재 위치를 비디오에 복원해야 했습니다.

**해결**
`AudioModeMixin`에서 진입/탈출 시 명시적으로 position을 전달하는 핸드오프 패턴을 구현했습니다.

```dart
// 오디오 모드 진입
Future<void> enterAudioOnlyMode() async {
  await controller!.pause();
  final pos = controller!.value.position;  // 비디오 위치 캡처

  final h = await BgAudio.instance.ensureAudioHandler();
  await (h as dynamic).loadSourceLocal(
    absolutePath: src,
    speed: playbackRate,
    clipBegin: scope == PlayScope.segment
        ? Duration(milliseconds: currentSegment.startMs) : null,
    clipEnd: scope == PlayScope.segment
        ? Duration(milliseconds: currentSegment.endMs) : null,
    loop: loopSegment,
  );
  await h.seek(pos);  // 비디오 위치를 오디오에 전달
  await h.pause();
}

// 오디오 모드 탈출
Future<void> exitAudioOnlyMode() async {
  final bgPos = (h as dynamic).position as Duration? ?? Duration.zero;
  await h.stop();

  // 세그먼트 범위 안에 있는지 검증 후 비디오에 복원
  var target = bgPos;
  if (scope == PlayScope.segment) {
    final st = Duration(milliseconds: currentSegment.startMs);
    final en = Duration(milliseconds: currentSegment.endMs);
    if (target < st || target >= en) target = st;
  }
  await controller!.seekTo(target);
  await controller!.setPlaybackSpeed(playbackRate);
}
```

핵심은 모드 전환 시 **세그먼트 범위 바운더리 체크**를 수행하는 것입니다. 오디오 엔진에서 세그먼트 끝을 넘어간 위치를 반환하면, 세그먼트 시작으로 리셋하여 "구간 반복" 맥락을 유지합니다.

---

### 문제 4 — AI 자막 생성 파이프라인의 비용 최적화와 에러 처리

**상황**
클립에 자막을 수동으로 입력하는 것은 매우 번거로운 작업입니다. OpenAI API를 활용하여 STT(음성→텍스트) + LLM(번역/발음 생성)을 자동화하는 "AI 드래프트" 기능을 도입했습니다. 그런데 하나의 클립에서 세그먼트가 20개 이상 나오면 LLM 호출 횟수가 급증하여 비용과 지연시간이 커지는 문제가 있었습니다.

**해결**
**배치 처리 + 프로그레스 콜백 + 코인 비용 산정** 구조를 설계했습니다.

```dart
Future<DraftResult> generate({ ... }) async {
  // 1) STT 수행 — Whisper API로 세그먼트 분리 (startMs, endMs, text)
  final asr = await transcribe(filePath: filePath, language: language, withSegments: true);

  // 2) LLM 배치 처리 — 5개씩 묶어서 한 번의 API 호출로 처리
  const batchSize = 5;
  for (int offset = 0; offset < asr.segments.length; offset += batchSize) {
    onProgress?.call(currentBatch, totalBatches, '번역 중 ($currentBatch/$totalBatches)');

    final batch = asr.segments.sublist(offset, min(offset + batchSize, asr.segments.length));
    final jsonStr = await llm.complete(
      systemPrompt: sys,
      userPrompt: '$userPrefix${jsonEncode(asrArray)}',
    );
    // JSON 응답에서 orig(원문), pron(발음), ko(번역) 추출
  }

  // 3) 코인 비용 = 영상 길이 30초당 1코인
  final coinCost = ((durationMs / 1000).ceil() + 29) ~/ 30;
  return DraftResult(segments: allDraftSegments, coinCost: coinCost);
}
```

STT와 LLM을 **Port 패턴**으로 추상화하여(`LLMPort`, `TranscribeUseCase`), 프로덕션에서는 OpenAI를, 테스트에서는 Mock을 주입할 수 있도록 했습니다. 또한 LLM 응답의 JSON 파싱 실패 시 해당 세그먼트만 빈 값으로 fallback하여 부분 실패를 허용하는 **best-effort recovery** 전략을 적용했습니다.

---

### 문제 5 — 백업/복원 시 대용량 미디어 파일로 인한 UI 프리징

**상황**
앱의 모든 데이터(SQLite DB + 미디어 파일)를 ZIP으로 압축하여 백업/복원하는 기능을 구현했습니다. 그런데 영상 파일이 수십 개에 달하면 압축 과정에서 메인 스레드가 수 초 동안 블로킹되어 앱이 멈추는 문제가 발생했습니다.

**해결**
Dart의 `compute()` (Isolate)를 사용하여 압축 작업을 별도 스레드에서 실행하도록 분리했습니다.

```dart
// 메인 스레드: UI + 프로그레스 업데이트만 담당
onProgress?.call(BackupProgress(state: BackupProgressState.compressing));

await compute(
  _doCompress,              // static 함수 (Isolate에서 실행)
  _CompressParams(          // Isolate에 전달할 직렬화 가능한 파라미터
    zipPath: backupZipPath,
    dbPath: db.path,
    filePaths: filePaths,   // 미디어 파일 목록
    timestamp: ts.toIso8601String(),
  ),
);
```

Isolate 내부에서는 **manifest.json**을 함께 생성하여 각 파일의 SHA256 해시와 크기를 기록합니다. 복원 시 이 manifest를 기준으로 **무결성 검증**을 수행하여, 손상된 백업 파일을 감지합니다.

```dart
// 복원 시 무결성 검증
for (final entry in manifestEntries) {
  final tmpFile = File(join(manifestDir.path, entry['path']));
  final expectedSha = entry['sha256'];
  final actualSha = await _sha256OfFile(tmpFile);
  if (actualSha != expectedSha) {
    throw StateError('Hash mismatch for ${entry["path"]}');
  }
}
```

또한 복원 실패에 대비하여 기존 DB를 `.bak` 파일로 백업해 둔 뒤 복원을 시도하고, 완료 후 `Restart.restartApp()`으로 앱을 재시작하여 Drift DB 커넥션을 깨끗하게 초기화합니다.

---

### 문제 6 — 세그먼트 구간 반복 재생의 타이밍 정밀도 문제

**상황**
플레이어의 핵심 기능인 "세그먼트 구간 반복"은 비디오가 세그먼트의 endMs에 도달하면 startMs로 되돌리는 방식입니다. `video_player`의 `addListener`로 매 프레임 위치를 체크하는데, 콜백 호출 간격에 따라 endMs를 수십 ms 넘어간 후에야 감지되는 경우가 있었습니다. 또한 `PlayScope.full`(전체 재생) 모드에서는 현재 위치에 해당하는 세그먼트 인덱스를 자동으로 추적해야 했습니다.

**해결**
`_onTick` 리스너에서 scope에 따라 다른 전략을 적용했습니다.

```dart
void _onTick() {
  final pos = _controller!.value.position;
  final start = Duration(milliseconds: currentSegment.startMs);
  final end = Duration(milliseconds: currentSegment.endMs);

  if (_scope == PlayScope.segment) {
    // 세그먼트 모드: 끝 도달 시 루프 또는 정지
    if (pos >= end) {
      if (_loopSegment) {
        _controller!.seekTo(start);
        _controller!.play();
      } else {
        _controller!.pause();
        _controller!.seekTo(end);   // 정확히 끝 위치에 고정
      }
    }
    // 시작 이전으로 벗어났으면 시작으로 복귀
    if (pos < start && _controller!.value.isPlaying) {
      _controller!.seekTo(start);
    }
  } else {
    // 전체 모드: 현재 위치에 해당하는 세그먼트 인덱스 자동 추적
    final idx = indexForPosition(pos);
    if (idx != null && idx != _segIndex) {
      _segIndex = idx;
    }
  }
  notifyListeners();
}
```

`seekTo`에서도 scope에 따라 **범위 클램핑**을 적용합니다. 세그먼트 모드에서는 `start ~ end` 범위를 벗어나지 못하도록, 전체 모드에서는 영상 전체 범위(`0 ~ duration`)로 클램핑합니다. 또한 시크 시 다른 세그먼트 범위로 넘어가면 `segIndex`를 자동으로 업데이트하여, 자막 오버레이가 자연스럽게 전환됩니다.

---

### 문제 7 — 도메인 로직의 UI 의존성 제거: sealed class와 Validator 패턴

**상황**
에디터 화면은 "생성 모드"와 "수정 모드" 두 가지가 있습니다. 초기에는 `isEditMode` boolean 플래그로 분기했는데, 수정 모드에서만 필요한 데이터(clipId, existingFilePath)를 nullable로 들고 다니면서 null 체크가 곳곳에 퍼졌습니다. 또한 폼 유효성 검증 로직이 ViewModel의 `save()` 메서드 안에 if-else로 인라인되어 있어 테스트와 재사용이 어려웠습니다.

**해결**
Dart 3의 **sealed class**로 모드를 타입 안전하게 표현하고, **Validator**를 순수 도메인 객체로 분리했습니다.

```dart
// sealed class로 모드 표현 — 패턴 매칭 강제
sealed class EditorMode {
  const EditorMode();
}

class CreateMode extends EditorMode {
  const CreateMode();
}

class EditMode extends EditorMode {
  final int clipId;              // non-nullable: 수정 모드에서는 반드시 존재
  final String? existingFilePath;
  const EditMode({required this.clipId, this.existingFilePath});
}

// 사용 시
switch (mode) {
  case CreateMode():
    // 새 클립 생성 로직
  case EditMode(:final clipId):
    // 기존 클립 수정 로직 — clipId가 보장됨
}
```

폼 유효성 검증은 `ClipValidator` 클래스로 분리하여 UI와 완전히 독립시켰습니다.

```dart
class ClipValidator {
  static const int maxDurationMs = 5 * 60 * 1000; // 5분

  ValidationResult validateForm(ClipFormData form) {
    if (form.filePath == null) return ValidationResult.invalid('영상 파일을 먼저 선택해 주세요.');
    if (form.clipTitle.trim().isEmpty) return ValidationResult.invalid('클립 제목은 필수입니다.');
    // ... 세그먼트 시간 범위, 겹침 검증 등
    return ValidationResult.valid();
  }

  ValidationResult validateSegments(List<SegmentInput> segments, int durationMs) {
    // 세그먼트 정렬 후 겹침(overlap) 검증
    for (int i = 1; i < sorted.length; i++) {
      if (currStart < prevEnd) {
        return ValidationResult.invalid('세그먼트 $i와 ${i+1}이 겹칩니다.');
      }
    }
  }
}
```

Validator는 Flutter에 의존하지 않는 순수 Dart 코드이므로, 유닛 테스트에서 위젯 없이 직접 검증할 수 있습니다. ViewModel은 저장 시 `validator.validateForm(formData)`만 호출하면 됩니다.

---

## 3. 아키텍처 설계

```bash
┌──────────────────────────────────────────────────────────────┐
│                       Flutter App                            │
│  Shorts (PageView) / Clip Editor / Player / Library          │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│               Presentation Layer (MVVM)                      │
│  ViewModel (ChangeNotifier + Mixins) ←→ Screen / Widgets     │
│  Provider로 위젯 트리에 ViewModel 주입                            │
└───────┬──────────────────────────────────────────────────────┘
        │
┌───────▼───────────────────────────────────────────────────────┐
│               Domain Layer (순수 Dart)                         │
│  sealed class (EditorMode), Validator, FormData, State enum   │
│  UI 프레임워크에 비의존적인 비즈니스 규칙                              │
└───────┬───────────────────────────────────────────────────────┘
        │
┌───────▼───────────────────────────────────────────────────────┐
│               Data Layer                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐  │
│  │ Drift (SQL)  │  │ Firebase     │  │ External APIs       │  │
│  │ Title/Release│  │ Auth         │  │ OpenAI (STT + LLM)  │  │
│  │ Episode/Clip │  │ Firestore    │  │ FFmpeg Kit          │  │
│  │ Segment/Tag  │  │              │  │ video_player        │  │
│  └──────────────┘  └──────────────┘  └─────────────────────┘  │
│                                                               │
│  Port/Adapter 패턴으로 외부 의존성 추상화                            │
│  UseCase → Service → Adapter (Port 인터페이스)                   │
└───────────────────────────────────────────────────────────────┘
```

**핵심 설계 결정**

| 결정 | 이유 |
|------|------|
| 4단계 계층 (Title → Release → Episode → Clip) | 작품-시즌-에피소드 구조를 DB 스키마에 그대로 반영하여, 폴더 뷰 탐색과 메타데이터 자동완성의 기반이 됨 |
| ViewModel mixin 분리 | ChangeNotifier 상속 트리를 복잡하게 만들지 않으면서 관심사를 물리적으로 분리 |
| Port/Adapter 패턴 | OpenAI API 같은 외부 의존성을 인터페이스 뒤에 숨겨 테스트 가능성 확보 |
| sealed class 모드 | 에디터의 생성/수정 모드를 타입 레벨에서 보장하여 런타임 null 체크 제거 |
| Isolate 백업 | 대용량 미디어 압축을 별도 스레드로 분리하여 UI 프리징 방지 |

---

## 4. 개발 과정

| 단계 | 내용 |
|------|------|
| **기반 설계** | 프로젝트 구조 설계, MVVM + Clean Architecture 레이어 분리, GoRouter 라우팅 |
| **데이터 레이어** | Drift DB 스키마 설계 (Title/Release/Episode/Clip/Segment/Tag), DAO 구현 |
| **클립 에디터** | 파일 선택 → 세그먼트 입력 → 메타데이터 관리 → DB 저장 플로우 구현 |
| **플레이어** | 세그먼트 구간 반복, 배속 조절, 자막 오버레이, 타임라인 네비게이션 |
| **쇼츠** | PageView 기반 세로 스와이프, Cycle Refresh, 광고 노출 로직 |
| **라이브러리** | 폴더 뷰 (4단계 계층 탐색), 태그 뷰 (필터링), 브레드크럼 네비게이션 |
| **AI 기능** | OpenAI Whisper STT + LLM 배치 번역, 코인 비용 산정 |
| **백그라운드 오디오** | just_audio + audio_service 연동, 비디오↔오디오 위치 동기화 |
| **수익화** | Google AdMob 광고, 인앱 결제(IAP), PortOne 결제 연동, 코인 시스템 |
| **백업/복원** | Isolate 압축, SHA256 무결성 검증, manifest 기반 복원 |

---

## 5. 성과 및 배운 점

### 기술적 성과

- **MVVM + Clean Architecture + Mixin 패턴**으로 기능별로 완전히 독립된 모듈 구조 달성 — 에디터, 플레이어, 쇼츠, 라이브러리가 core를 공유하면서도 서로 의존하지 않음
- **Cycle Refresh 패턴**으로 무한 스크롤의 메모리 누적 문제를 해결하면서도 사용자에게 끊김 없는 UX 제공
- **비디오 ↔ 오디오 핸드오프** 패턴으로 두 개의 독립된 미디어 엔진 간 재생 위치 동기화 구현
- **STT + LLM 배치 파이프라인**으로 수동 자막 입력 대비 클립 제작 시간을 대폭 단축
- **Isolate + SHA256 manifest**로 대용량 백업/복원의 안전성과 무결성을 보장

### 배운 점

- ChangeNotifier 기반 상태 관리에서 **mixin이 클래스 분리의 실질적 대안**이 될 수 있다는 것을 체감 — 단, mixin 간 상태 공유가 필요할 때는 abstract getter/setter 계약을 명확히 정의해야 혼란이 없음
- 무한 스크롤 UX를 구현할 때 **데이터 크기 관리를 처음부터 고려**해야 한다는 점 — "일단 추가하고 나중에 최적화"하면 PageController 인덱스 동기화 등 복잡한 문제가 겹침
- 두 개의 미디어 엔진(video_player ↔ just_audio) 사이의 전환은 단순히 position만 넘기면 되는 것이 아니라, **세그먼트 범위, 배속, 루프 설정 등 전체 재생 컨텍스트를 동기화**해야 사용자 경험이 자연스러움
- sealed class와 Validator 분리는 코드량은 약간 늘지만, ViewModel의 `save()` 메서드가 극적으로 단순해지고 **유효성 검증 로직을 독립적으로 테스트**할 수 있게 됨

---

## 6. 개선 가능한 부분

| 항목 | 현황 | 개선 방향 |
|------|------|-----------|
| 오프라인 학습 | 로컬 DB + 파일 기반 | 클라우드 동기화로 다중 기기 지원 |
| 추천 시스템 | 별도 백엔드 서버 (독립 프로젝트) | 앱 내 학습 이력 기반 개인화 추천 연동 |
| 성능 최적화 | 에피소드 선택 시 모든 클립의 썸네일 동기 추출 | 썸네일 캐시 레이어 도입, lazy loading |
| 테스트 커버리지 | Domain Validator 위주 | ViewModel 유닛 테스트, 위젯 테스트 확대 |
| AI 기능 | OpenAI API 단일 의존 | 로컬 Whisper 모델 옵션 추가로 비용 절감 |
| 플랫폼 | iOS / Android | 웹 버전 지원 (Flutter Web) |
