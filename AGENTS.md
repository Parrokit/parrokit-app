# AGENTS.md

이 파일은 이 저장소의 최상위 강제 규칙이다.

## 1) 우선순위

1. 사용자 요청
2. `AGENTS.md`
3. 기존 코드 패턴
4. 일반 관례

## 2) 작업 범위

1. 요청 범위 밖 수정 금지
2. 무관한 리팩터링/포맷 변경 금지
3. 생성 파일(`*.g.dart`, 플랫폼 generated)은 필요 시에만 갱신

## 3) 아키텍처

1. 기본: MVVM + Clean Architecture
2. `domain`: 순수 Dart(Flutter 의존 금지)
3. `data`: usecase/service/adapter/port
4. `presentation`: screen/view model/sections/widgets
5. 비즈니스 로직은 Widget이 아니라 service/usecase에 배치

## 4) 네이밍/스타일

1. `Screen`: `{Feature}Screen`
2. `Section`: `{Name}Section`
3. `Provider`: `{Feature}Provider`
4. `ViewModel`: `{Feature}ViewModel`
5. `UseCase`: `{Action}{Target}UseCase`
6. 축약어(`Btn`, `QA`) 금지
7. import 순서: `dart:*` -> `package:*` -> 로컬
8. async 이후 UI 접근 전 `mounted` 확인
9. 위젯 스타일 값(색상/폰트/간격)은 `AppTheme` 우선 사용(직접 하드코딩 최소화)

## 5) 파일 배치

1. 새 화면: 해당 feature의 `presentation/`
2. 재사용 UI: `presentation/widgets/`
3. 화면 전용 조립 블록: `presentation/sections/`
4. 2개 이상 feature 공통 로직만 `core/` 이동 검토

## 6) 검증 명령

루트:
```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

Functions:
```bash
cd functions
npm ci
npm run build
```

최소 규칙:
1. 수정 범위에 대해 `flutter analyze` 최소 1회 실행
2. Drift/Dart 모델 변경 시 build_runner 재생성 필요 여부 확인

## 7) 보안

1. 키/토큰/비밀값 코드/로그 노출 금지
2. `.env` 커밋 금지
3. `firestore.rules`, `storage.rules` 수정 시 최소 권한 원칙 적용

## 8) 보고 형식

완료 보고에 반드시 포함:
1. 변경 파일 목록
2. 동작 변화 요약
3. 실행한 검증 명령과 결과
4. 남은 리스크/후속 작업
5. 마지막 줄 단독: `[하네스 사용]`

## 9) 워크플로 참조 (토큰 절약)

1. 기본은 이 파일만 사용
2. 필요 시 인덱스 1개만 먼저 확인: `.agents/workflows/flutter-guide-index.md`
3. 세부 워크플로는 작업과 직접 관련된 1개만 추가 로드
4. 이미 확인한 규칙 재로딩 금지

## 10) 하네스 업데이트 규칙

1. 다음 경우에만 지침 업데이트:
   - 동일 실수/리뷰 지적이 2회 이상 반복
   - 기술 스택/폴더 구조/배포 절차가 실제 변경
2. 업데이트는 최소 변경 원칙(필요 문장만 수정)
3. 변경 시 이유를 커밋 메시지 또는 PR 본문에 1줄 기록
4. 상세 절차는 `.agents/workflows/harness-update-guideline.md` 참조

## 11) 커밋 메시지 규칙

1. 기본 형식: `feat: 한글로 짧은 한 줄`
2. 필요 시 타입만 변경: `fix:`, `refactor:`, `docs:`
3. 불필요한 장문 설명/이모지 사용 금지
4. 상세 규칙은 `.agents/workflows/commit-style-guideline.md` 참조
