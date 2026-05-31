---
description: Flutter 작업 시 자동으로 관련 가이드를 참조하도록 하는 메타 가이드
---

# Flutter 가이드 자동 참조

## 📌 이 파일의 목적

Flutter 코드 작업 시 **관련된 가이드를 자동으로 참조**하기 위한 매핑 정보.

---

## 📚 가이드 매핑

| 작업 키워드 | 참조할 가이드 |
|-------------|---------------|
| feature 생성, 새 화면 | `/flutter-architecture`, `/flutter-directory` |
| domain, usecase, service | `/flutter-architecture` |
| section, widget, 화면 분리 | `/flutter-sections-widgets` |
| 네이밍, 주석, 스타일 | `/flutter-naming` |
| core 이동, 모듈화 | `/flutter-modularization` |
| 폴더 구조, 파일 위치 | `/flutter-directory` |

---

## 🔄 자동 참조 규칙

**Flutter 관련 작업 시:**
1. 새 feature/화면 생성 → `/flutter-architecture`, `/flutter-directory` 읽기
2. Section/Widget 결정 → `/flutter-sections-widgets` 읽기
3. 파일/클래스 네이밍 → `/flutter-naming` 읽기
4. core로 이동 결정 → `/flutter-modularization` 읽기

---

## 사용 예시

```
사용자: "새 기능 만들어줘"
→ /flutter-architecture, /flutter-directory 참조

사용자: "이거 section으로 분리해줘"
→ /flutter-sections-widgets 참조

사용자: "네이밍 어떻게 해야 해?"
→ /flutter-naming 참조
```
