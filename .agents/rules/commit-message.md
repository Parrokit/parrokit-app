---
trigger: always_on
---

# Commit Message Rules

- 커밋 메시지는 항상 `[+] {type}: {변경 요약}` 형식으로 작성한다.
- type은 영어로 작성하며 `feat/fix/refactor/docs/test/chore/ci/build/perf/style/revert` 중 하나만 사용한다.
- 변경 요약은 한국어로 짧고 객관적으로 작성한다.
- 괄호, 이모지, 장문 설명, 내부 대화 맥락은 사용하지 않는다.
- 한 커밋에 여러 성격의 변경이 있으면 각 줄마다 `[+] {type}: {변경 요약}` 형식으로 나누어 작성한다.
- 문서 변경이 포함되면 요약에 문서 관련 키워드를 포함한다.

예시

```text
[+] feat: 커뮤니티 알림 기능 추가
[+] refactor: 커뮤니티 옵션 시트 통합
[+] docs: 커뮤니티 알림 요구사항 정리