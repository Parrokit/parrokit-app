---
description: 프로젝트 디렉터리 구조 및 파일 위치 가이드
---

# 디렉터리 구조 가이드

## 전체 디렉터리 구조

```
lib/
├── main.dart                # 앱 진입점 (최소화: bootstrap 호출만)
│
├── core/                    # 🔧 전역 공통 코드
│   ├── app.dart             # App 루트 위젯 (MaterialApp 설정)
│   ├── bootstrap.dart       # 앱 초기화 (Firebase, 광고, 인증 등)
│   ├── di/                  # 의존성 주입
│   │   └── providers.dart   # MultiProvider 목록
│   ├── config/              # 앱 설정
│   ├── provider/            # 전역 Provider (theme, auth, iap 등)
│   ├── repositories/        # Repository 추상화/구현
│   ├── services/            # 외부 서비스 (Firebase 등)
│   ├── router/              # 라우팅 설정
│   ├── navigation/          # 네비게이션 컴포넌트
│   ├── theme/               # 디자인 시스템
│   └── utils/               # 유틸리티 함수
│
├── data/                    # 💾 데이터 레이어 (전역)
│   ├── local/               # 로컬 DB (Drift)
│   ├── models/              # 공통 데이터 모델
│   └── constants/           # 상수 정의
│
└── features/                # 🎯 기능별 모듈
    ├── auth/
    ├── dashboard/
    ├── intro/
    └── ...
```

---

## main.dart 구조

```dart
// main.dart (최소화된 진입점)
import 'package:parrokit/core/bootstrap.dart';

void main() => bootstrap();
```

**역할 분리:**
| 파일 | 역할 |
|------|------|
| `main.dart` | 진입점 (bootstrap 호출만) |
| `core/bootstrap.dart` | 앱 초기화 (Firebase, 광고, 인증 등) |
| `core/app.dart` | App 위젯 (MaterialApp 설정) |
| `core/di/providers.dart` | MultiProvider 목록 |

---

## core/ 하위 폴더별 역할

```
core/
├── config/          # 앱 설정 (환경변수, 상수)
├── provider/        # 전역 상태 관리 (앱 전체에서 사용)
├── repositories/    # Repository 패턴 (데이터 접근 추상화)
├── services/        # 외부 서비스 래퍼 (Firebase, API 등)
├── router/          # 라우팅 설정
├── theme/           # 디자인 시스템
└── utils/           # 유틸리티 함수 (순수 함수, 헬퍼)
```
