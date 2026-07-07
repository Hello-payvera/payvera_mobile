const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

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