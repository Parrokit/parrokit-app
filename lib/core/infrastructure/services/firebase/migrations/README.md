# Firebase App Migration Notes

## coins_to_parrots

- 목적: 기존 Firestore `coins` 필드를 `parrots`로 승격하고, 이후 문서에서 `coins`를 제거한다.
- 위치: `lib/core/services/firebase/migrations/coins_to_parrots_migration.dart`
- 동작:
  - `parrots`와 `coins`가 함께 있으면 합산한다.
  - `coins`만 있으면 `parrots`로 옮긴다.
  - 읽는 시점에 문서를 한 번 갱신해 레거시 필드를 제거한다.
- 사용처: `FirebaseUserService`의 유저 문서 로딩 경로.
- 종료 기준: 백필 완료 후 앱에서 `coins` 호환 읽기와 이 문서를 제거한다.
