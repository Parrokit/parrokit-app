---
description: 작업 브랜치를 dev로 병합할 때의 표준 Git 플로우
---

# Git 병합 플로우 가이드

## 기본 순서

1. `git checkout dev`
2. `git pull origin dev`
3. `git merge [작업한 브랜치]`
4. `git push origin dev`
5. `git checkout [작업한 브랜치]`

## 규칙

1. 병합 전 작업 브랜치 변경사항은 반드시 커밋 완료 상태여야 한다.
2. `dev`에서 충돌 발생 시 충돌 해결 후 로컬 검증(`flutter analyze`)을 먼저 수행한다.
3. 병합 커밋 메시지는 기본 Git 메시지를 유지하거나 한 줄 한국어로 간결하게 작성한다.
4. 강제 푸시(`--force`)는 금지한다.
