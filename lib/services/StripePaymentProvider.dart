import 'dart:convert';
import 'package:fitmind_ai/config/key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentProvider extends ChangeNotifier {

  Future<void> makePayment() async {
    try {

      // 1. Create Payment Intent (Backend OR Stripe API)
      final paymentIntent = await _createPaymentIntent(
        amount: "5999", // $59.99
        currency: "usd",
      );

      // 2. Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: "FitMind AI",
          style: ThemeMode.dark,
        ),
      );

      // 3. Show Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint("Payment Success ✅");

    } catch (e) {
      debugPrint("Stripe Error ❌ $e");
      rethrow;
    }
  }

  /// Create PaymentIntent from Stripe API (TEMP without backend)
  Future<Map<String, dynamic>> _createPaymentIntent({
    required String amount,
    required String currency,
  }) async {

    const secretKey =
        (StripeKeys.secretKey); //  Only for testing

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

    return json.decode(response.body);
  }
}