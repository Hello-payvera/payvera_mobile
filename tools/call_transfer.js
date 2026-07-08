const { initializeApp } = require("firebase/app");
const {
  getAuth,
 connectAuthEmulator,
  signInWithEmailAndPassword,
} = require("firebase/auth");

const {
  getFunctions,
  connectFunctionsEmulator,
  httpsCallable,
} = require("firebase/functions");

const app = initializeApp({
  apiKey: "demo-api-key",
  authDomain: "payvera-42eca.firebaseapp.com",
  projectId: "payvera-42eca",
});

const auth = getAuth(app);
connectAuthEmulator(auth, "http://127.0.0.1:9099");

const functions = getFunctions(app);
connectFunctionsEmulator(functions, "127.0.0.1", 5001);

async function run() {
  console.log("Signing in...");

  await signInWithEmailAndPassword(
    auth,
    "sender@test.com",
    "Sender123!"
  );

  console.log("Authenticated.");

  const transfer = httpsCallable(functions, "internalTransfer");

  const result = await transfer({
    receiverPayveraId: "@receiver",
    amount: 500,
    description: "Local emulator transfer",
    idempotencyKey: Date.now().toString(),
  });

  console.log(result.data);
}

run().catch((e) => {
  console.error(e);
});