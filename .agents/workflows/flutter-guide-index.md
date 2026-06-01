---
description: Flutter 작업 시 자동으로 관련 가이드를 참조하도록 하는 메타 가이드
---

# Flutter 가이드 인덱스

## 목적

Flutter 작업 유형에 따라 참조할 워크플로 문서를 빠르게 고른다.

## 매핑

| 작업 키워드 | 참조할 가이드 |
|-------------|---------------|
| feature 생성, 새 화면 | `/flutter-architecture`, `/flutter-directory` |
| domain, usecase, service | `/flutter-architecture` |
| provider 비대화, provider 분리 | `/flutter-architecture` |
| section, widget, 화면 분리 | `/flutter-sections-widgets` |
| 네이밍, 주석, 스타일 | `/flutter-naming` |
| core 이동, 모듈화 | `/flutter-modularization` |
| 폴더 구조, 파일 위치 | `/flutter-directory` |
| API/FRD/Schema 문서화 | `/product-docs-guideline` |
| ADR/Runbook/Test-case/Changelog 문서화 | `/product-docs-guideline` |
| 코드 변경 후 문서 반영 | `/product-docs-guideline` |
| AGENTS/하네스 규칙 갱신 | `/harness-update-guideline` |
| 로그 규칙, QA 로그 점검 | `/logging-qa-guideline` |
| 커밋 메시지 스타일 | `/commit-style-guideline` |
| dev 병합, 브랜치 병합 순서 | `/git-merge-flow-guideline` |

## 기본 순서

1. 시작 선언: 선택한 역할 1개 + 워크플로 1개를 첫 진행 메시지에 경로 포함 명시
2. 구조 결정: `/flutter-architecture`, `/flutter-directory`
3. UI 분리: `/flutter-sections-widgets`
4. 이름/스타일: `/flutter-naming`
5. 공통화 판단: `/flutter-modularization`
6. 변경 문서 반영: `/product-docs-guideline`
7. 하네스 지침 갱신: `/harness-update-guideline`
8. 커밋 메시지 확인: `/commit-style-guideline`
9. 배포 전 병합 순서 확인: `/git-merge-flow-guideline`
