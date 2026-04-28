const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const crypto = require("crypto");
const {GoogleAuth} = require("google-auth-library");

admin.initializeApp();

const db = admin.firestore();
const NOTIFY_RADIUS_KM = 30;
const FIRST_MESSAGE_COST = 10;
const OFFER_COST = 5;
const REVIEW_BONUS = 5;
const DAILY_LOGIN_BONUS = 5;
const MONTHLY_SHARE_BONUS = 10;
const PRIVATE_CONTEXT_DOC_ID = "context";
const READY_FOOD_LIFETIME_DAYS = 2;
const DEFAULT_REQUEST_LIFETIME_DAYS = 7;
const APP_PACKAGE_NAME = "com.benyaparim.app";
const CREDIT_PACK_PRODUCTS = {
  credits_50: 50,
  credits_120: 120,
  credits_300: 300,
};
const COMMUNITY_TERMS_VERSION = "2026-04-ugc-safety";
const OBJECTIONABLE_PATTERNS = [
  /salak/iu,
  /aptal/iu,
  /gerizekali/iu,
  /orospu/iu,
  /pic/iu,
  /siktir/iu,
  /amk/iu,
];

exports.sendNotification = onDocumentCreated(
  "notifications/{id}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const data = snapshot.data();
    const receiverId = data.receiverId;
    if (!receiverId) {
      return;
    }

    const token = await getUserFcmToken(receiverId);
    if (!token) {
      return;
    }

    await admin.messaging().send({
      token,
      notification: {
        title: normalizeNotificationText(data.title || "Bildirim"),
        body: normalizeNotificationText(data.body || ""),
      },
      data: {
        requestId: data.requestId || "",
        type: data.type || "",
      },
    });
  },
);

exports.notifyNearbyUsersForNewRequest = onDocumentCreated(
  "requests/{requestId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const requestId = event.params.requestId;
    const request = snapshot.data();

    if (!request || request.requestType === "recipe") {
      return;
    }

    if (request.status && request.status !== "open") {
      return;
    }

    const ownerId = request.ownerId;
    const requestLat = toNumber(request.latitude);
    const requestLng = toNumber(request.longitude);

    if (!ownerId || requestLat === null || requestLng === null) {
      return;
    }

    const usersSnapshot = await db.collection("users").get();
    const batch = db.batch();
    let notifyCount = 0;

    for (const userDoc of usersSnapshot.docs) {
      if (userDoc.id === ownerId) {
        continue;
      }

      const privateContext = await getUserPrivateContext(userDoc.id);
      const userData = userDoc.data();
      const userLat = toNumber(privateContext.latitude ?? userData.latitude);
      const userLng = toNumber(privateContext.longitude ?? userData.longitude);

      if (userLat === null || userLng === null) {
        continue;
      }

      const distanceKm = calculateDistanceKm(
        requestLat,
        requestLng,
        userLat,
        userLng,
      );

      if (distanceKm > NOTIFY_RADIUS_KM) {
        continue;
      }

      const notificationRef = db.collection("notifications").doc();
      batch.set(notificationRef, {
        receiverId: userDoc.id,
        title: "Yakınınızda yeni ilan var",
        body: buildNearbyRequestBody(request),
        type: "nearby_request",
        requestId,
        ownerId,
        distanceKm: Number(distanceKm.toFixed(1)),
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      notifyCount += 1;
    }

    if (notifyCount > 0) {
      await batch.commit();
    }
  },
);

exports.cleanupExpiredRequests = onSchedule(
    {
      schedule: "every 60 minutes",
      timeZone: "Europe/Istanbul",
      region: "europe-west1",
    },
    async () => {
      const now = new Date();
      const requestsSnapshot = await db.collection("requests").get();

      if (requestsSnapshot.empty) {
        return;
      }

      const batch = db.batch();
      let deleteCount = 0;

      for (const doc of requestsSnapshot.docs) {
        const data = doc.data() || {};
        if (!shouldDeleteExpiredRequest(data, now)) {
          continue;
        }

        const ownerId = String(data.ownerId || "");
        if (ownerId) {
          const notificationRef = db.collection("notifications").doc();
          batch.set(notificationRef, {
            receiverId: ownerId,
            title: "İlan süresi doldu",
            body: "İlanın yayın süresi dolduğu için sistemden kaldırıldı.",
            type: "request_expired",
            requestId: doc.id,
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        batch.delete(doc.ref);
        deleteCount += 1;
      }

      if (deleteCount > 0) {
        await batch.commit();
      }
    },
);

exports.deleteRequest = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {requestId} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  if (!requestId || typeof requestId !== "string") {
    throw new HttpsError("invalid-argument", "Invalid request id");
  }

  const requestRef = db.collection("requests").doc(requestId);
  const requestSnap = await requestRef.get();

  if (!requestSnap.exists) {
    return {success: true};
  }

  const requestData = requestSnap.data() || {};
  if (String(requestData.ownerId || "") !== uid) {
    throw new HttpsError(
        "permission-denied",
        "Only the listing owner can delete this request",
    );
  }

  const refsToDelete = [];

  const orders = await requestRef.collection("orders").get();
  refsToDelete.push(...orders.docs.map((doc) => doc.ref));

  const offers = await db
      .collection("offers")
      .where("requestId", "==", requestId)
      .get();
  refsToDelete.push(...offers.docs.map((doc) => doc.ref));

  const notifications = await db
      .collection("notifications")
      .where("requestId", "==", requestId)
      .get();
  refsToDelete.push(...notifications.docs.map((doc) => doc.ref));

  const chats = await db
      .collection("chats")
      .where("requestId", "==", requestId)
      .get();

  for (const chatDoc of chats.docs) {
    const messages = await chatDoc.ref.collection("messages").get();
    refsToDelete.push(...messages.docs.map((doc) => doc.ref));

    const chatData = chatDoc.data() || {};
    const users = Array.isArray(chatData.users) ? chatData.users : [];
    for (const userId of users) {
      refsToDelete.push(
          db
              .collection("user_chats")
              .doc(String(userId))
              .collection("chats")
              .doc(chatDoc.id),
      );
    }

    refsToDelete.push(chatDoc.ref);
  }

  refsToDelete.push(requestRef);
  await deleteDocumentRefs(refsToDelete);

  return {success: true};
});

exports.useCredits = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {amount, action} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const numericAmount = Number(amount || 0);
  if (!Number.isInteger(numericAmount) || numericAmount <= 0) {
    throw new HttpsError("invalid-argument", "Invalid credit amount");
  }

  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const currentCredit = getCreditValue(userDoc.data());

    if (currentCredit < numericAmount) {
      throw new HttpsError("failed-precondition", "Yetersiz kredi");
    }

    applyCreditChange(
      tx,
      userRef,
      currentCredit - numericAmount,
      -numericAmount,
      action || "manual_use",
    );

    return {success: true, credit: currentCredit - numericAmount};
  });
});

exports.claimDailyLoginBonus = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const userData = userDoc.data() || {};
    const currentCredit = getCreditValue(userData);
    const lastLogin = timestampToDate(userData.lastLogin);

    if (lastLogin && Date.now() - lastLogin.getTime() < 24 * 60 * 60 * 1000) {
      return {success: false, alreadyClaimed: true, credit: currentCredit};
    }

    applyCreditChange(
      tx,
      userRef,
      currentCredit + DAILY_LOGIN_BONUS,
      DAILY_LOGIN_BONUS,
      "daily_bonus",
      {
        lastLogin: admin.firestore.FieldValue.serverTimestamp(),
      },
    );

    return {
      success: true,
      alreadyClaimed: false,
      credit: currentCredit + DAILY_LOGIN_BONUS,
    };
  });
});

exports.claimMonthlyShareReward = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const userRef = db.collection("users").doc(uid);
  const currentMonthKey = buildMonthKey(new Date());

  return db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const userData = userDoc.data() || {};
    const currentCredit = getCreditValue(userData);
    const lastClaimMonth = String(userData.lastShareRewardMonth || "");

    if (lastClaimMonth === currentMonthKey) {
      return {
        success: false,
        alreadyClaimed: true,
        credit: currentCredit,
      };
    }

    applyCreditChange(
        tx,
        userRef,
        currentCredit + MONTHLY_SHARE_BONUS,
        MONTHLY_SHARE_BONUS,
        "share_reward",
        {
          lastShareRewardMonth: currentMonthKey,
          lastShareRewardAt: admin.firestore.FieldValue.serverTimestamp(),
        },
    );

    return {
      success: true,
      alreadyClaimed: false,
      credit: currentCredit + MONTHLY_SHARE_BONUS,
    };
  });
});

exports.verifyAndGrantAndroidPurchase = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {productId, purchaseToken, purchaseId, source} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const normalizedProductId = String(productId || "");
  const creditsToGrant = CREDIT_PACK_PRODUCTS[normalizedProductId];
  if (!creditsToGrant) {
    throw new HttpsError("invalid-argument", "Unsupported product");
  }

  const normalizedToken = String(purchaseToken || "").trim();
  if (!normalizedToken) {
    throw new HttpsError("invalid-argument", "Missing purchase token");
  }

  if (source && String(source) !== "google_play") {
    throw new HttpsError("invalid-argument", "Unsupported purchase source");
  }

  const purchaseData = await verifyAndroidProductPurchase({
    packageName: APP_PACKAGE_NAME,
    productId: normalizedProductId,
    purchaseToken: normalizedToken,
  });

  const purchaseState = Number(purchaseData.purchaseState ?? -1);
  if (purchaseState !== 0) {
    throw new HttpsError("failed-precondition", "Purchase is not completed");
  }

  const receiptRef = db
      .collection("purchase_receipts")
      .doc(buildPurchaseReceiptId(normalizedProductId, normalizedToken));
  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const [receiptSnap, userSnap] = await Promise.all([
      tx.get(receiptRef),
      tx.get(userRef),
    ]);

    if (receiptSnap.exists) {
      const receiptData = receiptSnap.data() || {};
      return {
        success: true,
        alreadyGranted: true,
        grantedCredits: Number(receiptData.creditsGranted || creditsToGrant),
      };
    }

    const currentCredit = getCreditValue(userSnap.data());
    applyCreditChange(
        tx,
        userRef,
        currentCredit + creditsToGrant,
        creditsToGrant,
        `purchase_${normalizedProductId}`,
    );

    tx.set(receiptRef, {
      userId: uid,
      platform: "android",
      packageName: APP_PACKAGE_NAME,
      productId: normalizedProductId,
      purchaseId: String(purchaseId || purchaseData.orderId || ""),
      purchaseTokenHash: hashPurchaseToken(normalizedToken),
      orderId: String(purchaseData.orderId || ""),
      acknowledgementState: Number(purchaseData.acknowledgementState ?? -1),
      consumptionState: Number(purchaseData.consumptionState ?? -1),
      purchaseState,
      creditsGranted: creditsToGrant,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      raw: purchaseData,
    });

    return {
      success: true,
      alreadyGranted: false,
      grantedCredits: creditsToGrant,
    };
  });
});

exports.reportContent = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {
    targetUserId,
    contentType,
    contentId,
    reason,
    details,
    metadata,
  } = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const normalizedType = String(contentType || "").trim();
  const normalizedReason = String(reason || "").trim();
  if (!normalizedType || !normalizedReason) {
    throw new HttpsError("invalid-argument", "Missing report details");
  }

  const reportRef = db.collection("moderation_reports").doc();
  await reportRef.set({
    reporterId: uid,
    targetUserId: String(targetUserId || "").trim(),
    contentType: normalizedType,
    contentId: String(contentId || "").trim(),
    reason: normalizedReason,
    details: String(details || "").trim(),
    metadata: metadata || {},
    status: "open",
    termsVersion: COMMUNITY_TERMS_VERSION,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    reviewDeadlineAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 24 * 60 * 60 * 1000),
    ),
  });

  return {success: true, reportId: reportRef.id};
});

exports.blockUser = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {targetUserId, reason, details} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const normalizedTargetUserId = String(targetUserId || "").trim();
  if (!normalizedTargetUserId || normalizedTargetUserId === uid) {
    throw new HttpsError("invalid-argument", "Invalid target user");
  }

  const accountRef = getUserAccountRef(uid);
  const blockRef = getUserBlockRef(uid, normalizedTargetUserId);
  const reportRef = db.collection("moderation_reports").doc();

  const batch = db.batch();
  batch.set(blockRef, {
    blockedUserId: normalizedTargetUserId,
    reason: String(reason || "blocked_user").trim(),
    details: String(details || "").trim(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  batch.set(accountRef, {
    blockedUserIds: admin.firestore.FieldValue.arrayUnion(
        normalizedTargetUserId,
    ),
  }, {merge: true});
  batch.set(reportRef, {
    reporterId: uid,
    targetUserId: normalizedTargetUserId,
    contentType: "user_block",
    contentId: normalizedTargetUserId,
    reason: String(reason || "blocked_user").trim(),
    details: String(details || "").trim(),
    status: "open",
    termsVersion: COMMUNITY_TERMS_VERSION,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    reviewDeadlineAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 24 * 60 * 60 * 1000),
    ),
  });
  await batch.commit();

  return {success: true};
});

exports.unblockUser = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {targetUserId} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const normalizedTargetUserId = String(targetUserId || "").trim();
  if (!normalizedTargetUserId) {
    throw new HttpsError("invalid-argument", "Invalid target user");
  }

  const batch = db.batch();
  batch.delete(getUserBlockRef(uid, normalizedTargetUserId));
  batch.set(getUserAccountRef(uid), {
    blockedUserIds: admin.firestore.FieldValue.arrayRemove(
        normalizedTargetUserId,
    ),
  }, {merge: true});
  await batch.commit();

  return {success: true};
});

exports.sendOffer = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {requestId, ownerId, price, actionName, fromChat} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  if (!requestId || !ownerId) {
    throw new HttpsError("invalid-argument", "Missing request or owner");
  }

  const numericPrice = Number(price || 0);
  if (!Number.isFinite(numericPrice) || numericPrice <= 0) {
    throw new HttpsError("invalid-argument", "Invalid price");
  }

  if (uid === ownerId) {
    throw new HttpsError("failed-precondition", "Owner cannot send offer");
  }

  if (containsObjectionableContent(String(request.data?.details || ""))) {
    throw new HttpsError("invalid-argument", "Offer content is not allowed");
  }

  const blockedBetweenUsers = await isBlockedBetweenUsers(uid, ownerId);
  if (blockedBetweenUsers) {
    throw new HttpsError(
        "failed-precondition",
        "Bu kullanici ile etkilesim sinirlandirildi",
    );
  }

  const offerId = `${requestId}_${uid}`;
  const offerRef = db.collection("offers").doc(offerId);
  const requestRef = db.collection("requests").doc(requestId);
  const userRef = db.collection("users").doc(uid);
  const chatId = buildChatId(uid, ownerId, requestId);
  const chatRef = db.collection("chats").doc(chatId);

  return db.runTransaction(async (tx) => {
    const [offerDoc, requestDoc, userDoc, chatDoc] = await Promise.all([
      tx.get(offerRef),
      tx.get(requestRef),
      tx.get(userRef),
      tx.get(chatRef),
    ]);

    if (offerDoc.exists) {
      throw new HttpsError("already-exists", "Bu ilana zaten teklif verdiniz");
    }

    if (!requestDoc.exists) {
      throw new HttpsError("not-found", "Ilan bulunamadi");
    }

    const requestData = requestDoc.data() || {};
    if ((requestData.status || "open") !== "open") {
      throw new HttpsError("failed-precondition", "Ilan teklife kapali");
    }

    if ((requestData.ownerId || "") !== ownerId) {
      throw new HttpsError("permission-denied", "Owner mismatch");
    }

    const shouldChargeOffer = fromChat !== true;

    if (!shouldChargeOffer) {
      const chatData = chatDoc.data() || {};
      const users = Array.isArray(chatData.users) ? chatData.users : [];
      if (!chatDoc.exists || !users.includes(uid) || !users.includes(ownerId)) {
        throw new HttpsError(
            "permission-denied",
            "Sohbet icinden teklif verilemedi",
        );
      }
    }

    const currentCredit = getCreditValue(userDoc.data());
    if (shouldChargeOffer && currentCredit < OFFER_COST) {
      throw new HttpsError("failed-precondition", "Yetersiz kredi");
    }

    if (shouldChargeOffer) {
      applyCreditChange(
          tx,
          userRef,
          currentCredit - OFFER_COST,
          -OFFER_COST,
          actionName || "send_offer",
      );
    }

    tx.set(offerRef, {
      requestId,
      senderId: uid,
      requestOwnerId: ownerId,
      price: numericPrice,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const notificationRef = db.collection("notifications").doc();
    tx.set(notificationRef, {
      receiverId: ownerId,
        title: "Yeni teklif aldınız",
        body: `İlanınız için ₺${numericPrice} tutarında yeni bir teklif geldi.`, 
      type: "offer",
      requestId,
      senderId: uid,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {success: true, offerId};
  });
});

exports.acceptOffer = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {offerId, requestId} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  if (!offerId || !requestId) {
    throw new HttpsError("invalid-argument", "Missing offer or request");
  }

  const offerRef = db.collection("offers").doc(offerId);
  const requestRef = db.collection("requests").doc(requestId);

  let senderId = "";
  let ownerId = "";

  await db.runTransaction(async (tx) => {
    const requestSnap = await tx.get(requestRef);
    const offerSnap = await tx.get(offerRef);

    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "REQUEST_NOT_FOUND");
    }

    if (!offerSnap.exists) {
      throw new HttpsError("not-found", "OFFER_NOT_FOUND");
    }

    const requestData = requestSnap.data() || {};
    const offerData = offerSnap.data() || {};

    ownerId = requestData.ownerId || "";
    senderId = offerData.senderId || "";

    if (uid !== ownerId) {
      throw new HttpsError("permission-denied", "Only owner can accept");
    }

    if ((requestData.status || "open") !== "open") {
      throw new HttpsError("failed-precondition", "ALREADY_TAKEN");
    }

    if ((offerData.requestId || "") !== requestId) {
      throw new HttpsError("failed-precondition", "OFFER_MISMATCH");
    }

    tx.update(requestRef, {
      status: "in_progress",
      acceptedOfferId: offerId,
      acceptedUserId: senderId,
      ownerCompleted: false,
      workerCompleted: false,
      completedProcessed: false,
      reviewByOwner: false,
      reviewByWorker: false,
    });

    tx.update(offerRef, {
      status: "accepted",
    });
  });

  const offers = await db
      .collection("offers")
      .where("requestId", "==", requestId)
      .get();

  const batch = db.batch();
  for (const doc of offers.docs) {
    if (doc.id !== offerId) {
      batch.update(doc.ref, {status: "rejected"});
    }
  }

  const chatId = buildChatId(senderId, ownerId, requestId);
  batch.set(
      db.collection("chats").doc(chatId),
      {
        users: [senderId, ownerId].sort(),
        participants: {
          [senderId]: true,
          [ownerId]: true,
        },
        requestId,
        firstMessagePaidUsers: {
          [senderId]: true,
          [ownerId]: true,
        },
        lastMessage: "Teklif kabul edildi",
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );
  batch.set(
      db.collection("user_chats").doc(senderId).collection("chats").doc(chatId),
      {
        chatId,
        otherUserId: ownerId,
        lastMessage: "Teklif kabul edildi",
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );
  batch.set(
      db.collection("user_chats").doc(ownerId).collection("chats").doc(chatId),
      {
        chatId,
        otherUserId: senderId,
        lastMessage: "Teklif kabul edildi",
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );
  batch.set(
      db.collection("chats").doc(chatId),
      {
        firstMessagePaidUsers: {
          [senderId]: true,
          [ownerId]: true,
        },
        lastMessage: "Teklif kabul edildi",
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );
  batch.set(
      db.collection("notifications").doc(),
      {
        receiverId: senderId,
        title: "Teklifiniz kabul edildi",
        body: "İlan sahibi teklifinizi kabul etti. Mesajlaşmaya başlayabilirsiniz.",
        type: "offer_accepted",
        requestId,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
  );

  await batch.commit();

  return {success: true, chatId};
});

exports.featureRequest = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {requestId} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  if (!requestId) {
    throw new HttpsError("invalid-argument", "Missing request id");
  }

  const requestRef = db.collection("requests").doc(requestId);
  const userRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const [requestSnap, userSnap] = await Promise.all([
      tx.get(requestRef),
      tx.get(userRef),
    ]);

    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "Ilan bulunamadi");
    }

    const requestData = requestSnap.data() || {};
    if ((requestData.ownerId || "") !== uid) {
      throw new HttpsError("permission-denied", "Only owner can feature");
    }

    const featuredUntil = timestampToDate(requestData.featuredUntil);
    const isAlreadyFeatured =
      requestData.isFeatured === true &&
      featuredUntil &&
      featuredUntil.getTime() > Date.now();

    if (isAlreadyFeatured) {
      return {success: true, alreadyFeatured: true};
    }

    const currentCredit = getCreditValue(userSnap.data());
    if (currentCredit < 50) {
      throw new HttpsError("failed-precondition", "Yetersiz kredi");
    }

    applyCreditChange(tx, userRef, currentCredit - 50, -50, "feature");

    tx.update(requestRef, {
      isFeatured: true,
      featuredUntil: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
      ),
    });

    return {success: true, alreadyFeatured: false};
  });
});

exports.markRequestCompleted = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {requestId} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  if (!requestId) {
    throw new HttpsError("invalid-argument", "Missing request id");
  }

  const requestRef = db.collection("requests").doc(requestId);

  return db.runTransaction(async (tx) => {
    const requestSnap = await tx.get(requestRef);
    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "REQUEST_NOT_FOUND");
    }

    const data = requestSnap.data() || {};
    const ownerId = data.ownerId || "";
    const acceptedUserId = data.acceptedUserId || "";

    if (uid !== ownerId && uid !== acceptedUserId) {
      throw new HttpsError("permission-denied", "Not part of request");
    }

    const isOwner = uid === ownerId;
    const ownerCompleted = (data.ownerCompleted === true) || isOwner;
    const workerCompleted = (data.workerCompleted === true) || !isOwner;
    const alreadyProcessed = data.completedProcessed === true;

    tx.update(requestRef, {
      ownerCompleted,
      workerCompleted,
    });

    if (ownerCompleted && workerCompleted) {
      tx.update(requestRef, {
        status: "completed",
        completedProcessed: true,
      });

      if (!alreadyProcessed) {
        if (ownerId) {
          tx.update(db.collection("users").doc(ownerId), {
            completedOrders: admin.firestore.FieldValue.increment(1),
          });
        }

        if (acceptedUserId) {
          tx.update(db.collection("users").doc(acceptedUserId), {
            completedOrders: admin.firestore.FieldValue.increment(1),
          });
        }
      }
    }

    return {
      success: true,
      ownerCompleted,
      workerCompleted,
      completed: ownerCompleted && workerCompleted,
    };
  });
});

exports.submitReview = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {
    requestId,
    toUserId,
    isOwnerReview,
    rating,
    comment,
  } = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const numericRating = Number(rating || 0);
  if (!requestId || !toUserId || numericRating < 1 || numericRating > 5) {
    throw new HttpsError("invalid-argument", "Invalid review payload");
  }

  if (containsObjectionableContent(String(comment || ""))) {
    throw new HttpsError(
        "invalid-argument",
        "Yorum topluluk kurallarina aykiri ifadeler iceriyor",
    );
  }

  const reviewRef = db.collection("reviews").doc(`${requestId}_${uid}`);
  const requestRef = db.collection("requests").doc(requestId);
  const targetUserRef = db.collection("users").doc(toUserId);
  const reviewerRef = db.collection("users").doc(uid);

  return db.runTransaction(async (tx) => {
    const [reviewSnap, requestSnap, targetUserSnap, reviewerSnap] =
      await Promise.all([
        tx.get(reviewRef),
        tx.get(requestRef),
        tx.get(targetUserRef),
        tx.get(reviewerRef),
      ]);

    if (reviewSnap.exists) {
      throw new HttpsError("already-exists", "Bu is icin zaten yorum yaptin.");
    }

    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "Ilan bulunamadi");
    }

    const requestData = requestSnap.data() || {};
    const ownerId = requestData.ownerId || "";
    const acceptedUserId = requestData.acceptedUserId || "";
    const ownerReview = isOwnerReview === true;

    if (ownerReview && uid !== ownerId) {
      throw new HttpsError("permission-denied", "Only owner can leave this review");
    }

    if (!ownerReview && uid !== acceptedUserId) {
      throw new HttpsError("permission-denied", "Only assignee can leave this review");
    }

    const expectedTarget = ownerReview ? acceptedUserId : ownerId;
    if (!expectedTarget || expectedTarget !== toUserId) {
      throw new HttpsError("failed-precondition", "Review target mismatch");
    }

    if ((requestData.status || "") !== "completed") {
      throw new HttpsError("failed-precondition", "Is tamamlanmadi");
    }

    const targetUserData = targetUserSnap.data() || {};
    const reviewerData = reviewerSnap.data() || {};
    const oldRating = Number(targetUserData.ratingAverage || 0);
    const ratingCount = Number(targetUserData.ratingCount || 0);
    const newRating = ((oldRating * ratingCount) + numericRating) /
      (ratingCount + 1);
    const reviewerCredit = getCreditValue(reviewerData);

    tx.set(reviewRef, {
      requestId,
      reviewerId: uid,
      fromUserId: uid,
      targetUserId: toUserId,
      toUserId,
      rating: numericRating,
      comment: String(comment || "").trim(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.update(targetUserRef, {
      ratingAverage: newRating,
      ratingCount: ratingCount + 1,
    });

    tx.update(requestRef, {
      [ownerReview ? "reviewByOwner" : "reviewByWorker"]: true,
    });

    applyCreditChange(
      tx,
      reviewerRef,
      reviewerCredit + REVIEW_BONUS,
      REVIEW_BONUS,
      "review_bonus",
    );

    return {
      success: true,
      credit: reviewerCredit + REVIEW_BONUS,
    };
  });
});

exports.sendMessage = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  const {chatId, text} = request.data || {};

  if (!uid) {
    throw new HttpsError("unauthenticated", "User not logged in");
  }

  const trimmedText = String(text || "").trim();
  if (!chatId || !trimmedText) {
    throw new HttpsError("invalid-argument", "Missing chat or message");
  }

  const chatRef = db.collection("chats").doc(chatId);
  const userRef = db.collection("users").doc(uid);
  const firstMessageKey = `firstMessagePaidUsers.${uid}`;

  const [chatSnap, userSnap] = await Promise.all([
    chatRef.get(),
    userRef.get(),
  ]);

  if (!chatSnap.exists) {
    throw new HttpsError("not-found", "Chat bulunamadi");
  }

  const chatData = chatSnap.data() || {};
  const users = Array.isArray(chatData.users) ? chatData.users : [];
  if (!users.includes(uid)) {
    throw new HttpsError("permission-denied", "Chat participant required");
  }

  if (containsObjectionableContent(trimmedText)) {
    throw new HttpsError(
        "invalid-argument",
        "Mesaj topluluk kurallarina aykiri ifadeler iceriyor",
    );
  }

  const otherUserId = users.find((userId) => userId !== uid) || "";
  if (otherUserId) {
    const blockedBetweenUsers = await isBlockedBetweenUsers(uid, otherUserId);
    if (blockedBetweenUsers) {
      throw new HttpsError(
          "failed-precondition",
          "Bu kullanici ile etkilesim sinirlandirildi",
      );
    }
  }

  const requestId = String(chatData.requestId || "");
  let requestOwnerId = "";
  let requestType = "";
  if (requestId) {
    const requestSnap = await db.collection("requests").doc(requestId).get();
    requestOwnerId = String(requestSnap.data()?.ownerId || "");
    requestType = String(requestSnap.data()?.type || "");
  }

  const currentCredit = getCreditValue(userSnap.data());
  const alreadyPaid = Boolean(
      chatData.firstMessagePaidUsers &&
      chatData.firstMessagePaidUsers[uid] === true,
  );
  const senderIsOwner = requestOwnerId && requestOwnerId === uid;
  const isReadyFoodAutoStarter =
    requestType === "ready_food" &&
    trimmedText === "Sipariş vermek istiyorum.";
  const shouldChargeFirstMessage =
    !senderIsOwner && !alreadyPaid && !isReadyFoodAutoStarter;

  if (shouldChargeFirstMessage && currentCredit < FIRST_MESSAGE_COST) {
    throw new HttpsError(
        "failed-precondition",
        "Ilk mesaj icin 10 kredi gerekiyor",
    );
  }

  const batch = db.batch();

  if (shouldChargeFirstMessage) {
    batch.set(userRef, {
      credit: currentCredit - FIRST_MESSAGE_COST,
    }, {merge: true});

    const historyRef = userRef.collection("credit_history").doc();
    batch.set(historyRef, {
      action: "first_message",
      amount: -FIRST_MESSAGE_COST,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    batch.set(chatRef, {
      firstMessagePaidUsers: {
        [uid]: true,
      },
    }, {merge: true});
  }

  const messageRef = chatRef.collection("messages").doc();
  batch.set(messageRef, {
    text: trimmedText,
    senderId: uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const chatUpdates = {
    lastMessage: trimmedText,
    lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
  };

  for (const chatUserId of users) {
    chatUpdates[`deletedFor.${chatUserId}`] =
      admin.firestore.FieldValue.delete();
  }

  batch.set(chatRef, chatUpdates, {merge: true});

  const otherUsers = users.filter((userId) => userId !== uid);
  for (const otherUserId of otherUsers) {
    batch.set(
        db.collection("user_chats").doc(otherUserId).collection("chats").doc(chatId),
        {
          chatId,
          otherUserId: uid,
          lastMessage: trimmedText,
          lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
    );
    batch.set(
        db.collection("notifications").doc(),
        {
          receiverId: otherUserId,
          title: "Yeni mesaj",
          body: trimmedText,
          type: "chat_message",
          requestId: chatData.requestId || "",
          chatId,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
    );
  }

  batch.set(
      db.collection("user_chats").doc(uid).collection("chats").doc(chatId),
      {
        chatId,
        otherUserId,
        lastMessage: trimmedText,
        lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );

  await batch.commit();

  return {
    success: true,
    charged: shouldChargeFirstMessage,
    cost: shouldChargeFirstMessage ? FIRST_MESSAGE_COST : 0,
  };
});

async function verifyAndroidProductPurchase({packageName, productId, purchaseToken}) {
  const auth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  const client = await auth.getClient();
  const accessTokenResponse = await client.getAccessToken();
  const accessToken = typeof accessTokenResponse === "string" ?
    accessTokenResponse : accessTokenResponse.token;

  if (!accessToken) {
    throw new HttpsError(
        "internal",
        "Play doğrulama erişim belirteci alınamadı",
    );
  }

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}/purchases/products/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(purchaseToken)}`;
  const response = await fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new HttpsError(
        "permission-denied",
        `Play satın alma doğrulaması başarısız: ${body}`,
    );
  }

  return response.json();
}

function buildPurchaseReceiptId(productId, purchaseToken) {
  return `${productId}_${hashPurchaseToken(purchaseToken)}`;
}

function hashPurchaseToken(purchaseToken) {
  return crypto.createHash("sha256").update(String(purchaseToken)).digest("hex");
}
function getCreditValue(data) {
  if (!data) {
    return 0;
  }

  if (typeof data.credit === "number") {
    return data.credit;
  }

  if (typeof data.credits === "number") {
    return data.credits;
  }

  return 0;
}

function applyCreditChange(tx, userRef, nextValue, amountDelta, action, extraFields = {}) {
  tx.set(userRef, {
    credit: nextValue,
    ...extraFields,
  }, {merge: true});

  const historyRef = userRef.collection("credit_history").doc();
  tx.set(historyRef, {
    action,
    amount: amountDelta,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

function timestampToDate(value) {
  if (!value) {
    return null;
  }

  if (value.toDate) {
    return value.toDate();
  }

  return null;
}

async function deleteDocumentRefs(refs) {
  const chunkSize = 450;

  for (let start = 0; start < refs.length; start += chunkSize) {
    const batch = db.batch();
    const chunk = refs.slice(start, start + chunkSize);

    for (const ref of chunk) {
      batch.delete(ref);
    }

    await batch.commit();
  }
}

function buildChatId(userA, userB, requestId) {
  const users = [userA, userB].sort();
  return `${users[0]}_${users[1]}_${requestId}`;
}

function toNumber(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function calculateDistanceKm(lat1, lon1, lat2, lon2) {
  const earthRadiusKm = 6371;
  const dLat = degreesToRadians(lat2 - lat1);
  const dLon = degreesToRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(degreesToRadians(lat1)) *
      Math.cos(degreesToRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusKm * c;
}

function degreesToRadians(value) {
  return value * (Math.PI / 180);
}

function buildMonthKey(date) {
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

function buildNearbyRequestBody(request) {
  const title = request.title || "Yeni ilan";

  if (request.requestType === "design") {
    return `${title} organizasyon ilanı size 30 km içinde açıldı.`;
  }

  if (request.requestType === "delivery") {
    return `${title} taşıma ilanı size 30 km içinde açıldı.`;
  }

  if (request.type === "ready_food") {
    return `${title} hazır yemek ilanı size 30 km içinde açıldı.`;
  }

  return `${title} size 30 km içinde yeni ilan olarak açıldı.`;
}

function normalizeNotificationText(value) {
  const text = String(value || "");
  if (!text) {
    return text;
  }

  const hasMojibake = /[ÃÄÅâ]/.test(text);
  if (!hasMojibake) {
    return text;
  }

  try {
    return Buffer.from(text, "latin1").toString("utf8");
  } catch (error) {
    return text;
  }
}

function normalizeForModeration(value) {
  return String(value || "")
      .toLocaleLowerCase("tr-TR")
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, " ")
      .replace(/[^a-z0-9ğüşiöçı\s]/gi, " ")
      .replace(/\s+/g, " ")
      .trim();
}

function containsObjectionableContent(value) {
  const normalized = normalizeForModeration(value);
  if (!normalized) {
    return false;
  }

  return OBJECTIONABLE_PATTERNS.some((pattern) => pattern.test(normalized));
}

function shouldDeleteExpiredRequest(data, now = new Date()) {
  const status = String(data.status || "open");
  if (status !== "open" && status !== "active") {
    return false;
  }

  const expiresAt = timestampToDate(data.expiresAt);
  if (expiresAt) {
    return expiresAt.getTime() <= now.getTime();
  }

  const createdAt = timestampToDate(data.createdAt);
  if (!createdAt) {
    return false;
  }

  const lifetimeDays = getRequestLifetimeDays(data);
  const computedExpiry = new Date(
      createdAt.getTime() + lifetimeDays * 24 * 60 * 60 * 1000,
  );
  return computedExpiry.getTime() <= now.getTime();
}

function getRequestLifetimeDays(data) {
  const requestType = String(data.requestType || data.type || "");
  const isReady = data.isReady === true;

  if (requestType === "ready_food" || isReady) {
    return READY_FOOD_LIFETIME_DAYS;
  }

  return DEFAULT_REQUEST_LIFETIME_DAYS;
}

function getUserPrivateContextRef(userId) {
  return db.collection("users")
      .doc(userId)
      .collection("private")
      .doc(PRIVATE_CONTEXT_DOC_ID);
}

function getUserAccountRef(userId) {
  return db.collection("users").doc(userId)
      .collection("private").doc("account");
}

function getUserBlocksCollectionRef(userId) {
  return db.collection("users").doc(userId)
      .collection("private").doc("blocks").collection("items");
}

function getUserBlockRef(userId, targetUserId) {
  return getUserBlocksCollectionRef(userId).doc(targetUserId);
}

async function getBlockedUserIds(userId) {
  const accountSnapshot = await getUserAccountRef(userId).get();
  const accountData = accountSnapshot.exists ? (accountSnapshot.data() || {}) : {};
  const accountBlocked = Array.isArray(accountData.blockedUserIds) ?
    accountData.blockedUserIds.map((value) => String(value)) : [];

  const blockSnapshots = await getUserBlocksCollectionRef(userId).get();
  const blockDocIds = blockSnapshots.docs.map((doc) => String(doc.id));

  return Array.from(new Set([...accountBlocked, ...blockDocIds]));
}

async function isBlockedBetweenUsers(userA, userB) {
  const [userABlocked, userBBlocked] = await Promise.all([
    getBlockedUserIds(userA),
    getBlockedUserIds(userB),
  ]);

  return userABlocked.includes(userB) || userBBlocked.includes(userA);
}

async function getUserPrivateContext(userId) {
  const snapshot = await getUserPrivateContextRef(userId).get();
  return snapshot.exists ? (snapshot.data() || {}) : {};
}

async function getUserFcmToken(userId) {
  const privateContext = await getUserPrivateContext(userId);
  if (privateContext.fcmToken) {
    return String(privateContext.fcmToken);
  }

  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) {
    return "";
  }

  return String(userDoc.data().fcmToken || "");
}

