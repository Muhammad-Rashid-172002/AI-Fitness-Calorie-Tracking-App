const functions = require("firebase-functions");
const Stripe = require("stripe");

// Replace with your Stripe Secret Key
const stripe = new Stripe(StripeKeys.SecretKey);

exports.createPaymentIntent = functions.https.onCall(async (data) => {
  try {
    const amount = data.amount;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,           // amount in cents
      currency: "usd",
      automatic_payment_methods: {
        enabled: true,          // auto card / payment methods
      },
    });

    return { clientSecret: paymentIntent.client_secret };
  } catch (e) {
    console.log(e);
    throw new functions.https.HttpsError("internal", e.message);
  }
});