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
 Future<bool> makePayment({required bool isReActivation}) async {
  try {
    // Select correct amount
    final int amount = isReActivation ? 4485 : 2990;

    final paymentIntent = await _createPaymentIntent(amount);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        merchantDisplayName: "MyDiet",
        style: ThemeMode.dark,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    debugPrint("Payment Success ✅");

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final Timestamp premiumStart = Timestamp.now();
    final Timestamp premiumEnd = Timestamp.fromDate(
      premiumStart.toDate().add(const Duration(days: 14)),
    );

    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "premium": true,
      "premiumPlan": isReActivation ? "Re-Activation" : "Monthly",
      "premiumStart": premiumStart,
      "premiumEnd": premiumEnd,
    }, SetOptions(merge: true));

    notifyListeners();

    return true;
  } catch (e) {
    debugPrint("Stripe Error ❌ $e");
    return false;
  }
}/// Create PaymentIntent with Price ID
  Future<Map<String, dynamic>> _createPaymentIntent(int amount) async {
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
        "amount": amount.toString(), // ✅ Must be > 0
        "description": "FitMind AI Premium",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed: ${response.body}");
    }

    return json.decode(response.body);
  }
}
