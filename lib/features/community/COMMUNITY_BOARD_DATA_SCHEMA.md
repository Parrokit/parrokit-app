# Community Data Schema Guide

이 문서는 파로킷(Parrokit) 프로젝트의 `Community` 기능(게시판, 질문, 투표 등)에 대한 Firebase Firestore 데이터 구조 설계 가이드입니다. 

## 1. NoSQL 데이터 모델링 원칙
- **읽기(Read) 최적화**: Firestore는 RDBMS처럼 JOIN을 지원하지 않습니다. 게시판 목록(피드)을 렌더링할 때 유저의 닉네임과 프로필 사진을 가져오기 위해 별도의 쿼리를 날리면 읽기 비용이 크게 발생합니다. 따라서 **비정규화(Denormalization)**를 통해 작성자 정보를 `posts` 문서 안에 중복해서 저장해야 합니다.
- **용량 제한과 하위 컬렉션(Subcollection)**: 문서 하나당 용량 제한은 1MB입니다. 무한히 늘어날 수 있는 댓글이나 '좋아요' 목록은 배열 대신 하위 컬렉션으로 분리합니다.

## 2. 컬렉션 구조 요약
- `users` (루트 컬렉션) : 유저 기본 정보
- `posts` (루트 컬렉션) : 커뮤니티 모든 게시글 (자유게시판, 질문, 투표 등)
  - `comments` (하위 컬렉션) : 해당 게시글의 댓글들
  - `likes` (하위 컬렉션) : 해당 게시글에 좋아요를 누른 유저 기록

---

## 3. 상세 스키마 설계

### 3.1. `users` 컬렉션
사용자의 프로필 기본 정보입니다.
```json
// Path: users/{uid}
{
  "uid": "user1234",
  "nickname": "파로킷유저",
  "avatarUrl": "https://...",
  "createdAt": "2026-05-20T10:00:00Z"
}
```

### 3.2. `posts` 컬렉션 (게시글)
게시글의 본문, 메타데이터, 목록 표출용 최적화 데이터가 모두 포함됩니다.

```json
// Path: posts/{postId}
{
  // 1. 기본 정보 및 분류 (💡 필터링/정렬의 핵심 필드들)
  "postType": "board",             // 커뮤니티 형식 (board, question, vote)
  "category": "팁/노하우",           // 게시글 성격 (자유, 질문, 팁/노하우, 스터디 모집 등)
  "targetLanguage": "en",          // 💡 학습 언어 필터 (고정 외국어 분류: en, ja, es 등)
  
  // 2. 글 내용
  "title": "넷플릭스 쉐도잉하기 좋은 미드 추천", 
  "content": "비즈니스 영어를 배우려면 오피스가 제일 낫고...",  // 본문 전체 (HTML이나 Markdown 등)
  "tags": ["미드", "쉐도잉", "초보"],  // 유저가 자유롭게 입력하는 태그 (검색 보조용)
  
  // 2. 작성자 정보 (💡 비정규화: 리스트 렌더링 최적화)
  "authorId": "user1234",          // 유저 고유 ID (권한 확인, 프로필 이동용)
  "authorNickname": "파로킷유저",
  "authorAvatarUrl": "https://...",

  // 3. 리스트 표시 최적화 데이터
  "snippet": "프로젝트 시작하려는데...",  // 피드 목록에 보여줄 짧은 요약 텍스트
  "hasImage": true,                // 피드에 썸네일 아이콘을 띄울지 여부
  "imageUrls": ["https://..."],    // 이미지 URL 배열 (첫 번째 이미지를 썸네일로 활용)

  // 4. 통계 및 반응 (카운터)
  "viewCount": 0,                  // 조회수 (인기글 정렬용)
  "likeCount": 0,                  // 좋아요 수
  "commentCount": 0,               // 댓글 수
  "scrapCount": 0,                 // 스크랩(저장) 수

  // 5. 관리 및 상태 필드
  "status": "active",              // active, deleted(소프트 삭제), hidden(블라인드)
  "reportCount": 0,                // 누적 신고 횟수
  
  // 6. 시간 정보
  "createdAt": "2026-05-20T10:15:00Z", // Timestamp
  "updatedAt": "2026-05-20T10:15:00Z"  // Timestamp ("수정됨" 표시용)
}
```

### 3.3. `comments` 하위 컬렉션 (게시판의 댓글 및 대댓글)
파이어베이스에서 대댓글(Reply)을 구현할 때는 **절대 하위 컬렉션(`comments/{id}/replies`)을 따로 만들지 않는 것이 좋습니다.** 
만약 따로 만들면 UI를 그릴 때 댓글 개수만큼 쿼리(N+1 쿼리 문제)를 날려야 해서 요금과 성능에 치명적입니다. 
대신, 같은 `comments` 컬렉션 안에 넣고 `parentId` 필드로 구분하는 **Flat 구조**를 강력히 권장합니다.

```json
// Path: posts/{postId}/comments/{commentId}
{
  "authorId": "user5678",
  "authorNickname": "개발자토끼",
  "authorAvatarUrl": "https://...",
  
  "content": "저는 Riverpod 추천합니다!",
  
  // 💡 대댓글(Reply) 구현을 위한 핵심 필드
  "parentId": null,          // null이면 최상위 댓글, 값이 있으면 특정 댓글의 대댓글
  "replyToNickname": null,   // (선택) 누구에게 남긴 대댓글인지 멘션 표시용
  
  "likeCount": 5,
  "status": "active",
  "createdAt": "2026-05-20T10:20:00Z",
  "updatedAt": "2026-05-20T10:20:00Z"
}
```
Flutter(클라이언트)에서는 `comments`를 한 번의 쿼리로 몽땅 가져온 뒤, `parentId`가 `null`인 원본 댓글들 밑에 같은 아이디를 가진 대댓글들을 끼워맞춰서(Tree 구조화) UI를 그립니다.

### 3.4. 질문글(Q&A) 전용 하위 컬렉션 구조 (`answers`)
질문글의 경우 단순한 댓글이 아니라 **"답변"**이라는 특수성이 있으므로, `comments` 대신 `answers`라는 하위 컬렉션을 씁니다. 그리고 그 답변에 달리는 피드백 대화들은 `answers` 하위의 `comments`에 저장합니다.

```json
// 1. 답변 (Answer) 문서
// Path: posts/{postId}/answers/{answerId}
{
  "authorId": "expertUser",
  "authorNickname": "플러터마스터",
  "content": "상태관리는 Riverpod을 가장 추천합니다...",
  
  "isAdopted": true,      // 질문자가 이 답변을 채택했는지 여부
  "upvoteCount": 15,      // 답변 추천(도움돼요) 수
  "commentCount": 2,      // 이 답변에 달린 댓글 수
  
  "createdAt": "2026-05-20T11:00:00Z"
}

// 2. 답변에 달리는 댓글 (Comment) 문서
// Path: posts/{postId}/answers/{answerId}/comments/{commentId}
{
  "authorId": "user1234",
  "content": "아하! 그럼 Provider에서 넘어가는 건 어렵지 않을까요?",
  "parentId": null,       // 여기서도 대댓글이 필요하면 사용
  "createdAt": "2026-05-20T11:15:00Z"
}
```

### 3.5. 투표(Vote) 기능 데이터
투표글(`postType: "vote"`)의 경우 투표 데이터를 `posts` 문서 내부에 포함시키고, 중복 투표 방지용 컬렉션을 따로 둡니다.
```json
{
  "postType": "vote",              // 투표글
  "voteOptions": [
    { "id": "1", "text": "재택 근무", "count": 260 },
    { "id": "2", "text": "사무실 출근", "count": 80 }
  ],
  "voteEndTime": "2026-05-25T10:00:00Z"
}
```
- **중복 방지용 하위 컬렉션:** `posts/{postId}/voters/{userId}`에 유저별 투표 기록을 남겨 방어합니다.

---

## 4. 고려해볼 만한 개발 포인트
1. **페이징 (Pagination):** 게시글을 피드에 표시할 때 한 번에 10~20개씩 가져오도록 `limit()`과 `startAfterDocument()`를 활용합니다.
2. **트랜잭션 (Transaction) / 배치 (Batch):** 사용자가 좋아요를 누르거나 댓글을 쓸 때 `likes`나 `comments` 하위 컬렉션에 문서를 생성함과 동시에 `posts` 문서의 `likeCount`나 `commentCount`를 `1` 증가시켜야 합니다. 이때 일관성을 유지하기 위해 트랜잭션이나 배치를 사용합니다.
3. **닉네임 변경 동기화:** 사용자가 닉네임을 변경할 때 기존 작성한 글(`posts`)과 댓글(`comments`)의 `authorNickname`을 일괄 업데이트할지, 혹은 Cloud Functions를 통해 백그라운드에서 동기화할지 기획적 결정이 필요합니다.
