/* eslint-disable require-jsdoc, max-len, indent */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import {onSchedule} from "firebase-functions/v2/scheduler";

const db = admin.firestore();

const boardTypeLabelMap: Record<string, string> = {
  board: "일반",
  question: "질문",
  vote: "투표",
};

type NotificationPayload = {
  recipientUserId: string;
  notificationType: "post_comment" | "comment_reply" | "vote_end";
  boardType: string;
  postId: string;
  commentId?: string;
  parentCommentId?: string;
  actorId: string;
  actorDisplayName?: string;
  title: string;
  body: string;
  routePath: string;
};

export const onCommunityCommentCreated = functions
  .region("asia-northeast3")
  .firestore.document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const commentData = snapshot.data() as Record<string, unknown>;
    const postId = context.params.postId;
    const commentId = context.params.commentId;
    const authorId = asString(commentData.authorId);
    if (!authorId) return;

    const postSnap = await db.collection("posts").doc(postId).get();
    if (!postSnap.exists) return;

    const postData = postSnap.data() as Record<string, unknown>;
    const boardType = asString(postData.postType) || "board";
    const postAuthorId = asString(postData.authorId);
    const actorDisplayName = asString(commentData.authorNickname);
    const parentId = asString(commentData.parentId);

    const recipientMap = new Map<string, NotificationPayload>();

    if (postAuthorId && postAuthorId !== authorId) {
      recipientMap.set(
        postAuthorId,
        buildCommentNotification({
          recipientUserId: postAuthorId,
          notificationType: "post_comment",
          boardType,
          postId,
          commentId,
          parentCommentId: parentId ?? undefined,
          actorId: authorId,
          actorDisplayName: actorDisplayName ?? undefined,
          routePath: buildRoutePath(boardType, postId),
          title: buildCommentTitle(boardType),
          body: buildCommentBody(boardType, actorDisplayName ?? undefined),
        })
      );
    }

    if (parentId) {
      const parentSnap = await db
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(parentId)
        .get();

      if (parentSnap.exists) {
        const parentData = parentSnap.data() as Record<string, unknown>;
        const parentAuthorId = asString(parentData.authorId);
        const parentAuthorNickname = asString(parentData.authorNickname);

        if (parentAuthorId && parentAuthorId !== authorId) {
          recipientMap.set(
            parentAuthorId,
            buildCommentNotification({
              recipientUserId: parentAuthorId,
              notificationType: "comment_reply",
              boardType,
              postId,
              commentId,
              parentCommentId: parentId ?? undefined,
              actorId: authorId,
              actorDisplayName: actorDisplayName ?? undefined,
              routePath: buildRoutePath(boardType, postId),
              title: buildReplyTitle(boardType),
              body: buildReplyBody(
                boardType,
                actorDisplayName ?? undefined,
                parentAuthorNickname ?? undefined,
              ),
            })
          );
        }
      }
    }

    await Promise.all(
      Array.from(recipientMap.values()).map(async (payload) => {
        await saveNotification(payload);
        await safeSendPushNotification(payload);
      }),
    );
  });

export const onVoteEndNotification = onSchedule(
  "every 10 minutes",
  async () => {
    const now = new Date();
    const voteSnapshot = await db
      .collection("posts")
      .where("postType", "==", "vote")
      .get();

    const duePosts = voteSnapshot.docs.filter((doc) => {
      const data = doc.data() as Record<string, unknown>;
      const voteEndTime = asString(data.voteEndTime);
      const notifiedAt = data.voteEndNotificationSentAt;
      if (notifiedAt) return false;
      if (!voteEndTime) return false;

      const endDate = new Date(voteEndTime);
      return !Number.isNaN(endDate.getTime()) && endDate <= now;
    });

    for (const postDoc of duePosts) {
      const postId = postDoc.id;
      const postData = postDoc.data() as Record<string, unknown>;
      const postTitle = asString(postData.title) || "투표";
      const routePath = buildRoutePath("vote", postId);

      const votersSnapshot = await db
        .collectionGroup("voted_posts")
        .where("postId", "==", postId)
        .get();

      await Promise.all(
        votersSnapshot.docs.map(async (doc) => {
          const userId = doc.ref.parent.parent?.id;
          if (!userId) return;

        const payload = buildVoteEndNotification({
            recipientUserId: userId,
            boardType: "vote",
            postId,
            actorId: "system",
            title: "투표가 종료되었어요.",
            body: `${postTitle} 결과를 확인해 보세요.`,
            routePath,
          });

          await saveNotification(payload);
          await safeSendPushNotification(payload);
        }),
      );

      await postDoc.ref.set(
        {
          voteEndNotificationSentAt: admin.firestore.Timestamp.now(),
          updatedAt: admin.firestore.Timestamp.now(),
        },
        {merge: true},
      );
    }
  },
);

async function saveNotification(payload: NotificationPayload): Promise<void> {
  const notificationId = buildNotificationId(payload);
  const docRef = db
    .collection("users")
    .doc(payload.recipientUserId)
    .collection("notifications")
    .doc(notificationId);

  const notificationData: Record<string, unknown> = {
    recipientUserId: payload.recipientUserId,
    notificationType: payload.notificationType,
    boardType: payload.boardType,
    postId: payload.postId,
    actorId: payload.actorId,
    title: payload.title,
    body: payload.body,
    routePath: payload.routePath,
    isRead: false,
    createdAt: admin.firestore.Timestamp.now(),
    readAt: null,
  };

  if (payload.commentId) {
    notificationData.commentId = payload.commentId;
  }
  if (payload.parentCommentId) {
    notificationData.parentCommentId = payload.parentCommentId;
  }
  if (payload.actorDisplayName) {
    notificationData.actorDisplayName = payload.actorDisplayName;
  }

  await docRef.set(
    notificationData,
    {merge: true},
  );
}

async function safeSendPushNotification(payload: NotificationPayload): Promise<void> {
  try {
    const userSnap = await db.collection("users").doc(payload.recipientUserId).get();
    if (!userSnap.exists) return;

    const userData = userSnap.data() as Record<string, unknown>;
    const tokens = (userData.fcmTokens as unknown[] | undefined)
      ?.map((value) => String(value))
      .filter((token) => token.length > 0) ?? [];

    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        notificationId: buildNotificationId(payload),
        notificationType: payload.notificationType,
        boardType: payload.boardType,
        postId: payload.postId,
        commentId: payload.commentId ?? "",
        parentCommentId: payload.parentCommentId ?? "",
        routePath: payload.routePath,
        actorId: payload.actorId,
        actorDisplayName: payload.actorDisplayName ?? "",
      },
    });
  } catch (error) {
    console.error("[CommunityNotification][FCM] send failed", error);
  }
}

function buildNotificationId(payload: NotificationPayload): string {
  const commentPart = payload.commentId ?? "post";
  return [
    payload.notificationType,
    payload.postId,
    commentPart,
    payload.recipientUserId,
  ].join("_");
}

function buildCommentNotification(payload: NotificationPayload): NotificationPayload {
  return payload;
}

function buildVoteEndNotification(payload: Omit<NotificationPayload, "notificationType" | "commentId" | "parentCommentId" | "actorDisplayName">): NotificationPayload {
  return {
    ...payload,
    notificationType: "vote_end",
  };
}

function buildRoutePath(boardType: string, postId: string): string {
  switch (boardType) {
    case "question":
      return `/community/question/${postId}`;
    case "vote":
      return `/community/vote/${postId}`;
    default:
      return `/community/board/${postId}`;
  }
}

function buildCommentTitle(boardType: string): string {
  return `${boardTypeLabelMap[boardType] ?? "게시글"}에 새 댓글이 달렸어요.`;
}

function buildReplyTitle(boardType: string): string {
  return `${boardTypeLabelMap[boardType] ?? "게시글"} 댓글에 답글이 달렸어요.`;
}

function buildCommentBody(boardType: string, actorDisplayName?: string): string {
  const label = boardTypeLabelMap[boardType] ?? "게시글";
  const actor = actorDisplayName && actorDisplayName.length > 0 ? actorDisplayName : "누군가";
  return `${actor}님이 ${label}에 댓글을 남겼어요.`;
}

function buildReplyBody(
  boardType: string,
  actorDisplayName?: string,
  parentDisplayName?: string,
): string {
  const label = boardTypeLabelMap[boardType] ?? "게시글";
  const actor = actorDisplayName && actorDisplayName.length > 0 ? actorDisplayName : "누군가";
  const parent = parentDisplayName && parentDisplayName.length > 0 ? parentDisplayName : "내 댓글";
  return `${actor}님이 ${label}의 ${parent}에 답글을 남겼어요.`;
}

function asString(value: unknown): string | null {
  if (typeof value === "string" && value.length > 0) {
    return value;
  }
  return null;
}
