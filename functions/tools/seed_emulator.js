const admin = require("firebase-admin");

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8085";
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";

admin.initializeApp({
  projectId: "payvera-42eca",
});

const db = admin.firestore();

async function createUser(email, password, fullName, payveraId, walletId, balance) {
  let user;

  try {
    user = await admin.auth().getUserByEmail(email);
  } catch (_) {
    user = await admin.auth().createUser({
      email,
      password,
      displayName: fullName,
    });
  }

  await db.collection("users").doc(user.uid).set({
    uid: user.uid,
    fullName,
    email,
    payveraId,
    walletId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection("wallets").doc(walletId).set({
    walletId,
    ownerUid: user.uid,
    currency: "NGN",
    status: "active",
    balance,
    availableBalance: balance,
    ledgerBalance: balance,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`${email} created`);
}

async function run() {
  await createUser(
    "sender@test.com",
    "Sender123!",
    "Sender User",
    "@sender",
    "wallet_sender",
    10000
  );

  await createUser(
    "receiver@test.com",
    "Receiver123!",
    "Receiver User",
    "@receiver",
    "wallet_receiver",
    500
  );

  console.log("Done.");
}

run().catch(console.error);