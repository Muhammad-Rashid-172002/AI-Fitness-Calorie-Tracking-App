import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentProvider extends ChangeNotifier {
  /// Make Payment using Stripe Price IDs
  /// Returns true if payment successful, false otherwise
  Future<bool> makePayment({
    required bool isReActivation,
  }) async {
    try {
      // 1️⃣ Select Price ID based on plan
      final String priceId = isReActivation
          ? StripeKeys.reActivationPriceId // Replace with your re-activation Price ID
          : StripeKeys.monthlyPriceId;     // Replace with your monthly Price ID

      // 2️⃣ Create PaymentIntent using Price ID
      final paymentIntent = await _createPaymentIntentWithPriceId(priceId);

      // 3️⃣ Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: "FitMind AI",
          style: ThemeMode.dark,
        ),
      );

      // 4️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint("Payment Success ✅");

      // 5️⃣ Update Firebase user document with premium + 14-day free trial
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final Timestamp premiumStart = Timestamp.now();
      final Timestamp premiumEnd = Timestamp.fromDate(
        premiumStart.toDate().add(const Duration(days: 14)), // 14 days free trial
      );

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "premium": true,
        "premiumPlan": isReActivation ? "Re-Activation" : "Monthly",
        "premiumStart": premiumStart,
        "premiumEnd": premiumEnd,
      }, SetOptions(merge: true));

      debugPrint("User premium status updated with 14-day trial 🟢");

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Stripe Error ❌ $e");
      return false;
    }
  }

  /// Create PaymentIntent with Price ID
  Future<Map<String, dynamic>> _createPaymentIntentWithPriceId(String priceId) async {
    const secretKey = StripeKeys.secretKey;

    final response = await http.post(
      Uri.parse("https://api.stripe.com/v1/payment_intents"),
      headers: {
        "Authorization": "Bearer $secretKey",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "currency": "myr",
        "payment_method_types[]": "card",
        "amount": "0", // Amount managed via Price ID in subscription flow
        "description": "FitMind AI Premium",
        "metadata[price_id]": priceId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create Payment Intent: ${response.body}");
    }

    return json.decode(response.body);
  }
}