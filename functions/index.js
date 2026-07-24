const admin = require("firebase-admin");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions");

admin.initializeApp();

const db = getFirestore();

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
console.log("================================");
console.log("internalTransfer called");
console.log("AUTH:", request.auth);
console.log("DATA:", request.data);
console.log("================================");
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
      receiverUid,
      receiverName:
        receiverUser.fullName ||
        receiverUser.displayName ||
        "",
      receiverPayveraId:
        receiverUser.payveraId || "",
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

exports.fundWallet = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Login required."
    );
  }

  const uid = request.auth.uid;

  const amount = Number(request.data.amount);
  const reference = request.data.reference;

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid amount."
    );
  }

  if (!reference) {
    throw new HttpsError(
      "invalid-argument",
      "Reference is required."
    );
  }

  const userRef = db.collection("users").doc(uid);

  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    throw new HttpsError(
      "not-found",
      "User not found."
    );
  }

  const user = userDoc.data();

  const walletRef = db.collection("wallets").doc(user.walletId);

  const walletDoc = await walletRef.get();

  if (!walletDoc.exists) {
    throw new HttpsError(
      "not-found",
      "Wallet not found."
    );
  }

  const wallet = walletDoc.data();

  const available =
      Number(wallet.availableBalance ?? 0);

  const ledger =
      Number(wallet.ledgerBalance ?? 0);

  await walletRef.update({
    availableBalance: available + amount,
    ledgerBalance: ledger + amount,
    updatedAt: FieldValue.serverTimestamp(),
  });

  const txRef = db.collection("transactions").doc();

  await txRef.set({
    transactionId: txRef.id,
    ownerUid: uid,
    walletId: user.walletId,
    type: "walletFunding",
    direction: "credit",
    status: "successful",
    amount: amount,
    currency: wallet.currency ?? "NGN",
    provider: "paystack",
    providerReference: reference,
    reference: reference,
    description: "Wallet Funding",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    completedAt: FieldValue.serverTimestamp(),
  });

  return {
    success: true,
    message: "Wallet funded successfully.",
    balance: available + amount,
  };
});
