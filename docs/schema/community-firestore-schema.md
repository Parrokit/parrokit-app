# Community Firestore Schema

## 1) 목적
커뮤니티(Board/Question/Vote) 데이터 구조를 구현 코드와 일치하게 정의한다.

## 2) 범위 (In/Out)
- In: `users`, `posts`, `comments`, `likes`, `voters`, `reports` 컬렉션 구조
- Out: 보상 정책 상세, 관리자 운영 UI 상세

## 3) 데이터 계약

### 3.1 컬렉션 구조
- `users/{uid}`
- `posts/{postId}`
- `posts/{postId}/comments/{commentId}`
- `posts/{postId}/likes/{uid}`
- `posts/{postId}/voters/{uid}`
- `reports/{reportId}`

### 3.2 users
```json
{
  "uid": "user1234",
  "nickname": "parro_user",
  "avatarUrl": "https://...",
  "blockedUserIds": ["uidA", "uidB"],
  "createdAt": "Timestamp"
}
```

### 3.3 posts (공통)
```json
{
  "postType": "board",
  "category": "free",
  "targetLanguage": "en",
  "title": "...",
  "content": "...",
  "tags": ["shadowing"],
  "snippet": "...",
  "imageUrls": ["https://..."],
  "hasImage": true,
  "authorId": "user1234",
  "authorNickname": "parro_user",
  "authorAvatarUrl": "https://...",
  "viewCount": 0,
  "likeCount": 0,
  "commentCount": 0,
  "scrapCount": 0,
  "reportCount": 0,
  "status": "active",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### 3.4 comments (Flat)
```json
{
  "authorId": "user5678",
  "authorNickname": "dev_rabbit",
  "authorAvatarUrl": "https://...",
  "content": "...",
  "parentId": null,
  "replyToNickname": null,
  "likeCount": 0,
  "status": "active",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```
- `parentId == null`: 최상위 댓글
- `parentId != null`: 대댓글

### 3.5 question 전용 필드
```json
{
  "postType": "question",
  "requiredCrackers": 0,
  "acceptedCommentId": null
}
```

### 3.6 vote 전용 필드
```json
{
  "postType": "vote",
  "voteOptions": [
    { "id": "1", "text": "Option A", "count": 10 },
    { "id": "2", "text": "Option B", "count": 8 }
  ],
  "voteEndTime": "Timestamp"
}
```
```json
{
  "selectedOption": 1,
  "votedAt": "Timestamp"
}
```

### 3.7 reports
```json
{
  "reporterId": "user1234",
  "targetType": "post",
  "targetId": "post_001",
  "reportedUserId": "user9999",
  "reason": "abuse",
  "createdAt": "Timestamp"
}
```

## 4) 예외/에러 규칙
- 좋아요/댓글/투표는 트랜잭션 또는 배치로 처리해 카운터 불일치를 방지한다.
- `status != active` 문서는 피드 조회 기본 대상에서 제외한다.
- 차단 유저(`blockedUserIds`)는 클라이언트 후처리 필터를 적용한다.

## 5) 수용 기준
- `postType` 기준 Board/Question/Vote 분기 조회가 가능하다.
- 댓글은 `parentId`로 트리 구성 가능하다.
- 투표는 `voters/{uid}`로 중복 투표 방지가 가능하다.
- 스키마 변경 시 모델/리포지토리/인덱스/문서가 함께 갱신된다.

## 6) 변경 이력
- 2026-06-01: `docs/schema/` 경로로 스키마 문서 재정렬 및 템플릿 표준화
