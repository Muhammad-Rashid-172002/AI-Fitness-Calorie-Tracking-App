// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PremiumController {

//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;

//   // Buy Premium
//   Future<void> buyPremium() async {

//     try {

//       Offerings offerings = await Purchases.getOfferings();

//       if (offerings.current == null) return;

//       Package package =
//           offerings.current!.availablePackages.first;

//       CustomerInfo info =
//           await Purchases.purchasePackage(package);

//       if (info.entitlements.active.containsKey("premium")) {

//         await _firestore
//             .collection("users")
//             .doc(_auth.currentUser!.uid)
//             .update({
//           "isPremium": true,
//           "plan": "monthly",
//         });
//       }

//     } catch (e) {
//       print("Purchase Failed: $e");
//     }
//   }
// }