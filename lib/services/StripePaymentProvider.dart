import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentProvider extends ChangeNotifier {
  /// Make Payment
  /// Returns true if payment successful, false otherwise
  Future<bool> makePayment({
    required bool isReActivation,
  }) async {
    try {
      String amount;

      // Monthly RM 29.90 = 2990 cents
      if (isReActivation) {
        // 3 Months at 50% discount = 44.85 → 4485 cents
        amount = "4485";
      } else {
        // Normal Monthly
        amount = "2990";
      }

      // 1️⃣ Create Payment Intent
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: "myr",
      );

      // 2️⃣ Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: "FitMind AI",
          style: ThemeMode.dark,
        ),
      );

      // 3️⃣ Show Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint("Payment Success ✅");

      // 4️⃣ Update Firebase user document with premium + 14-day free trial
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final Timestamp premiumStart = Timestamp.now();
      final Timestamp premiumEnd = Timestamp.fromDate(
        premiumStart.toDate().add(const Duration(days: 14)), // 14 days free trial
      );

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "premium": true,                      // mark user as premium
        "premiumPlan": isReActivation ? "Re-Activation" : "Monthly",
        "premiumStart": premiumStart,
        "premiumEnd": premiumEnd,             // free trial end date
      }, SetOptions(merge: true));

      debugPrint("User premium status updated with 14-day trial 🟢");

      // Notify listeners to update UI
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Stripe Error ❌ $e");
      return false;
    }
  }

  /// Create PaymentIntent
  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    const secretKey = StripeKeys.secretKey;

    final response = await http.post(
      Uri.parse("https://api.stripe.com/v1/payment_intents"),
      headers: {
        "Authorization": "Bearer $secretKey",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "amount": amount,
        "currency": currency,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create Payment Intent: ${response.body}");
    }

    return json.decode(response.body);
  }
}