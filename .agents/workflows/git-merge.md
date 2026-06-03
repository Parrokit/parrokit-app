---
description: Git Merge Workflow
---

# Git Merge Workflow

## 기본 순서

1. `git checkout dev`
2. `git pull origin dev`
3. `git merge [작업 브랜치]`
4. `git push origin dev`
5. `git checkout [작업 브랜치]`

## 규칙

- 병합 전 작업 브랜치 변경사항은 모두 커밋한다.
- 병합 전 `dev`를 최신 상태로 맞춘다.
- 병합 후 반드시 원래 작업 브랜치로 돌아온다.
- 5번 단계는 생략하지 않는다.
- 충돌이 발생하면 해결 후 `flutter analyze`를 실행한다.
- 병합 커밋 메시지는 기본 Git 메시지를 유지하거나 한국어 한 줄로 작성한다.
- `--force` 푸시는 사용하지 않는다.