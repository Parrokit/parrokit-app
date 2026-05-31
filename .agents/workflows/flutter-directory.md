---
description: 프로젝트 디렉터리 구조 및 파일 위치 가이드
---

# 디렉터리 구조 가이드

## 기본 구조

```
lib/
├── main.dart        # bootstrap 호출만
├── core/            # 전역 공통(설정, 라우터, 테마, 전역 provider)
├── data/            # 전역 데이터(local/models/constants)
└── features/        # 기능별 모듈
```

## core/ 역할

```
core/
├── config/      # 앱 설정
├── provider/    # 전역 상태
├── repositories/# 공통 데이터 추상화
├── services/    # 외부 서비스 래퍼
├── router/      # 라우팅
├── theme/       # 디자인 시스템
└── utils/       # 유틸 함수
```

## 배치 규칙

1. 화면/기능 전용 코드는 `features/{feature}`에 둔다.
2. 2개 이상 feature에서 공유되는 코드만 `core` 또는 `shared`로 이동한다.
3. `main.dart`는 초기화 로직을 넣지 않고 진입점만 유지한다.
