const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");
admin.initializeApp();

const stripe = Stripe(functions.config().stripe.secret_key);

// Cancel Subscription Function
exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  const uid = context.auth.uid;
  const subscriptionId = data.subscriptionId;

  if (!subscriptionId) throw new functions.https.HttpsError("invalid-argument", "Subscription ID required");

  try {
    // Cancel Stripe subscription immediately
    await stripe.subscriptions.del(subscriptionId);

    // Update Firestore
    await admin.firestore().collection("users").doc(uid).update({
      premium: false,
      canceledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});