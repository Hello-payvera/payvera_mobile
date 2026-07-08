const {setGlobalOptions} = require("firebase-functions");
const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");

admin.initializeApp();

const db = admin.firestore();

setGlobalOptions({
  maxInstances: 10,
  region: "us-central1",
});

exports.healthCheck = onRequest((request, response) => {
  response.status(200).json({
    status: "ok",
    service: "payvera-functions",
    message: "Payvera backend is running",
    timestamp: new Date().toISOString(),
  });
});

function generateReference(prefix = "PV") {
  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000000)
      .toString()
      .padStart(6, "0");

  return `${prefix}-${timestamp}-${random}`;
}

exports.internalTransfer = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required.");
  }

  const senderUid = request.auth.uid;
  const {
    receiverPayveraId,
    amount,
    description,
    idempotencyKey,
  } = request.data || {};

  if (!receiverPayveraId || typeof receiverPayveraId !== "string") {
    throw new HttpsError("invalid-argument", "Receiver Payvera ID is required.");
  }

  if (!idempotencyKey || typeof idempotencyKey !== "string") {
    throw new HttpsError("invalid-argument", "Idempotency key is required.");
  }

  const numericAmount = Number(amount);

  if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
    throw new HttpsError("invalid-argument", "Amount must be greater than zero.");
  }

  const transferDescription =
    typeof description === "string" && description.trim().length > 0 ?
      description.trim() :
      "Payvera wallet transfer";

  const normalizedReceiverId = receiverPayveraId.trim().toLowerCase();

  const senderUserRef = db.collection("users").doc(senderUid);
  const idempotencyRef = db.collection("idempotencyKeys").doc(idempotencyKey);

  return db.runTransaction(async (transaction) => {
    const idempotencyDoc = await transaction.get(idempotencyRef);

    if (idempotencyDoc.exists) {
      return idempotencyDoc.data().response;
    }

    const senderUserDoc = await transaction.get(senderUserRef);

    if (!senderUserDoc.exists) {
      throw new HttpsError("not-found", "Sender profile not found.");
    }

    const senderUser = senderUserDoc.data();
    const senderWalletId = senderUser.walletId;

    if (!senderWalletId) {
      throw new HttpsError("failed-precondition", "Sender wallet not found.");
    }

    const receiverQuery = await transaction.get(
        db.collection("users")
            .where("payveraId", "==", normalizedReceiverId)
            .limit(1),
    );

    if (receiverQuery.empty) {
      throw new HttpsError("not-found", "Receiver not found.");
    }

    const receiverUserDoc = receiverQuery.docs[0];
    const receiverUser = receiverUserDoc.data();
    const receiverUid = receiverUser.uid;
    const receiverWalletId = receiverUser.walletId;

    if (!receiverWalletId) {
      throw new HttpsError("failed-precondition", "Receiver wallet not found.");
    }

    if (receiverUid === senderUid) {
      throw new HttpsError("failed-precondition", "You cannot send money to yourself.");
    }

    const senderWalletRef = db.collection("wallets").doc(senderWalletId);
    const receiverWalletRef = db.collection("wallets").doc(receiverWalletId);

    const senderWalletDoc = await transaction.get(senderWalletRef);
    const receiverWalletDoc = await transaction.get(receiverWalletRef);

    if (!senderWalletDoc.exists || !receiverWalletDoc.exists) {
      throw new HttpsError("not-found", "Wallet record missing.");
    }

    const senderWallet = senderWalletDoc.data();
    const receiverWallet = receiverWalletDoc.data();

    if (senderWallet.status !== "active" || senderWallet.isFrozen === true) {
      throw new HttpsError("failed-precondition", "Sender wallet is not active.");
    }

    if (receiverWallet.status !== "active" || receiverWallet.isFrozen === true) {
      throw new HttpsError("failed-precondition", "Receiver wallet is not active.");
    }

    const senderAvailable = Number(
        senderWallet.availableBalance ?? senderWallet.balance ?? 0,
    );

    if (senderAvailable < numericAmount) {
      throw new HttpsError("failed-precondition", "Insufficient wallet balance.");
    }

    const receiverAvailable = Number(
        receiverWallet.availableBalance ?? receiverWallet.balance ?? 0,
    );

    const senderLedger = Number(
        senderWallet.ledgerBalance ?? senderWallet.balance ?? 0,
    );

    const receiverLedger = Number(
        receiverWallet.ledgerBalance ?? receiverWallet.balance ?? 0,
    );

    const reference = generateReference("PVT");
    const now = FieldValue.serverTimestamp();

    const senderTransactionRef = db.collection("transactions").doc();
    const receiverTransactionRef = db.collection("transactions").doc();

    const senderTransaction = {
      transactionId: senderTransactionRef.id,
      reference,
      walletId: senderWalletId,
      ownerUid: senderUid,
      type: "payveraIdTransfer",
      direction: "debit",
      status: "successful",
      amount: numericAmount,
      fee: 0.0,
      currency: senderWallet.currency || "NGN",
      description: transferDescription,
      counterpartyWalletId: receiverWalletId,
      counterpartyPayveraId: receiverUser.payveraId || normalizedReceiverId,
      provider: "payvera_internal",
      providerReference: reference,
      idempotencyKey,
      createdAt: now,
      updatedAt: now,
      completedAt: now,
    };

    const receiverTransaction = {
      transactionId: receiverTransactionRef.id,
      reference,
      walletId: receiverWalletId,
      ownerUid: receiverUid,
      type: "payveraIdTransfer",
      direction: "credit",
      status: "successful",
      amount: numericAmount,
      fee: 0.0,
      currency: receiverWallet.currency || "NGN",
      description: transferDescription,
      counterpartyWalletId: senderWalletId,
      counterpartyPayveraId: senderUser.payveraId || "",
      provider: "payvera_internal",
      providerReference: reference,
      idempotencyKey,
      createdAt: now,
      updatedAt: now,
      completedAt: now,
    };

    transaction.update(senderWalletRef, {
      availableBalance: senderAvailable - numericAmount,
      ledgerBalance: senderLedger - numericAmount,
      updatedAt: now,
    });

    transaction.update(receiverWalletRef, {
      availableBalance: receiverAvailable + numericAmount,
      ledgerBalance: receiverLedger + numericAmount,
      updatedAt: now,
    });

    transaction.set(senderTransactionRef, senderTransaction);
    transaction.set(receiverTransactionRef, receiverTransaction);

    const response = {
      success: true,
      reference,
      amount: numericAmount,
      currency: senderWallet.currency || "NGN",
      senderTransactionId: senderTransactionRef.id,
      receiverTransactionId: receiverTransactionRef.id,
    };

    transaction.set(idempotencyRef, {
      key: idempotencyKey,
      ownerUid: senderUid,
      operation: "internalTransfer",
      response,
      createdAt: now,
      updatedAt: now,
    });

    return response;
  });
});