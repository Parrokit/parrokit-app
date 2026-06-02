# Bootstrap 폴더 안내

이 폴더는 앱 시작 초기화 코드를 역할별로 분리한다.

## 파일 구성

- `bootstrap.dart`: 앱 시작 오케스트레이션(초기화 순서만 담당)
- `bootstrap_dependencies.dart`: Provider/의존 객체 생성 및 연결
- `bootstrap_steps.dart`: 단계 함수 export 배럴 파일
- `steps/*.dart`: 초기화 단계 구현 파일

## steps 파일 원칙

- 단계별 파일 분리(`initXxx` 단위)
- 기능 변경 없이 초기화 책임만 담당
- 로그 포맷은 `[Bootstrap][Step] ...` 유지
