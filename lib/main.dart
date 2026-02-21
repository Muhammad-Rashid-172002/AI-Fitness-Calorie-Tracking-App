import 'package:firebase_core/firebase_core.dart';
import 'package:fitmind_ai/config/key.dart';


import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/services/StripePaymentProvider.dart';
import 'package:fitmind_ai/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = (StripeKeys.publishableKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => StripePaymentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitMind AI',
        home: const SplashScreen(),
      ),
    );
  }
}
