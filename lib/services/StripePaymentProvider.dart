import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentProvider extends ChangeNotifier {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  /// isReActivation = true => 50% discount
  Future<void> makePayment({required bool isReActivation}) async {
    // 🚫 Prevent double click
    if (_isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    try {
      String amount;

      // Price Logic
      if (isReActivation) {
        amount = "4485"; // 3 months 50% off
      } else {
        amount = "2990"; // Monthly
      }

      // 1️⃣ Create Payment Intent
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: "myr",
      );

      if (paymentIntent['client_secret'] == null) {
        throw Exception("Payment Intent failed");
      }

      // 2️⃣ Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: "FitMind AI",
          style: ThemeMode.dark,
          allowsDelayedPaymentMethods: true,
        ),
      );

      // 3️⃣ Present Payment Sheet
      try {
        await Stripe.instance.presentPaymentSheet();
        await Stripe.instance.confirmPaymentSheetPayment();

        debugPrint("Payment Successful ✅");
      } on StripeException catch (e) {
        debugPrint("Payment Cancelled ❌: ${e.error.localizedMessage}");
        throw Exception("Payment Cancelled");
      }

      // 4️⃣ Update Firebase
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "premium": true,
        "premiumPlan": isReActivation ? "Re-Activation" : "Monthly",
        "premiumStart": Timestamp.now(),
        "trialEnds": Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 14)),
        ),
      }, SetOptions(merge: true));

      debugPrint("Firebase Updated ✅");

      notifyListeners();
    } catch (e) {
      debugPrint("Stripe Error ❌: $e");
    } finally {
      // 🔓 Unlock button
      _isProcessing = false;
      notifyListeners();
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
        "payment_method_types[]": "card",
      },
    );

    return json.decode(response.body);
  }
}
