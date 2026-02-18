import 'package:firebase_core/firebase_core.dart';
import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProfileController())],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitMind AI',
        home: const SplashScreen(),
      ),
    );
  }
}
