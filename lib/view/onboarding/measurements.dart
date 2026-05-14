// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fitmind_ai/components/showCustomSnackBar.dart';
// import 'package:fitmind_ai/view/onboarding/target_screen.dart';
// import 'package:flutter/material.dart';

// class MeasurementsScreen extends StatefulWidget {
//   const MeasurementsScreen({super.key});

//   @override
//   State<MeasurementsScreen> createState() => _MeasurementsScreenState();
// }

// class _MeasurementsScreenState extends State<MeasurementsScreen> {
//   final TextEditingController heightController = TextEditingController(
//     text: "170",
//   );

//   final TextEditingController weightController = TextEditingController(
//     text: "70",
//   );

//   final TextEditingController ageController = TextEditingController(text: "25");

//   bool isLoading = false;

//   /// SAVE DATA TO FIREBASE
//   Future<void> saveMeasurements() async {
//     String uid = FirebaseAuth.instance.currentUser!.uid;

//     if (heightController.text.isEmpty ||
//         weightController.text.isEmpty ||
//         ageController.text.isEmpty) {
//       showCustomSnackBar(context, "Please fill all fields", false);
//       return;
//     }

//     try {
//       setState(() {
//         isLoading = true;
//       });

//       await FirebaseFirestore.instance.collection("users").doc(uid).set({
//         "height": heightController.text.trim(),
//         "weight": weightController.text.trim(),
//         "age": ageController.text.trim(),
//         "updatedAt": DateTime.now(),
//       }, SetOptions(merge: true));

//       setState(() {
//         isLoading = false;
//       });

//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(
//       //     content: Text("Measurements Saved"),
//       //   ),
//       // );

//       // NEXT SCREEN
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => TargetWeightScreen(
//             height: double.parse(heightController.text.trim()),
//             weight: double.parse(weightController.text.trim()),
//           ),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF071120),

//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF06101F), Color(0xFF0A1830), Color(0xFF06101F)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),

//         child: SafeArea(
//           child: Stack(
//             children: [
//               /// MAIN UI
//               SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 22,
//                   vertical: 10,
//                 ),

//                 child: Column(
//                   children: [
//                     /// TOP BAR
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Skip",
//                           style: TextStyle(
//                             color: Color(0xFF94A3B8),
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),

//                         Row(
//                           children: [
//                             _progress(false),
//                             _progress(true),
//                             _progress(false),
//                           ],
//                         ),

//                         const Text(
//                           "2/3",
//                           style: TextStyle(
//                             color: Color(0xFF94A3B8),
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 90),

//                     /// ICON
//                     Container(
//                       height: 120,
//                       width: 120,

//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),

//                         gradient: LinearGradient(
//                           colors: [
//                             const Color(0xFF22C55E).withOpacity(0.20),

//                             const Color(0xFF06B6D4).withOpacity(0.20),
//                           ],
//                         ),
//                       ),

//                       child: const Center(
//                         child: Icon(
//                           Icons.straighten_rounded,
//                           color: Color(0xFF22C55E),
//                           size: 55,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 35),

//                     /// TITLE
//                     const Text(
//                       "Your measurements",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 38,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     const Text(
//                       "Help us calculate your goals",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Color(0xFF94A3B8), fontSize: 18),
//                     ),

//                     const SizedBox(height: 40),

//                     /// HEIGHT
//                     _measurementCard(
//                       title: "Height (cm)",
//                       icon: Icons.straighten_rounded,
//                       iconColor: const Color(0xFF22C55E),
//                       controller: heightController,
//                     ),

//                     const SizedBox(height: 18),

//                     /// WEIGHT
//                     _measurementCard(
//                       title: "Weight (kg)",
//                       icon: Icons.monitor_weight_outlined,
//                       iconColor: const Color(0xFF06B6D4),
//                       controller: weightController,
//                     ),

//                     const SizedBox(height: 18),

//                     /// AGE
//                     _measurementCard(
//                       title: "Age",
//                       icon: Icons.calendar_month_outlined,
//                       iconColor: const Color(0xFF22C55E),
//                       controller: ageController,
//                     ),

//                     const SizedBox(height: 150),
//                   ],
//                 ),
//               ),

//               /// CONTINUE BUTTON
//               Positioned(
//                 bottom: 25,
//                 left: 22,
//                 right: 22,

//                 child: Container(
//                   height: 70,

//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),

//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
//                     ),

//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF22C55E).withOpacity(0.35),
//                         blurRadius: 25,
//                         spreadRadius: 1,
//                       ),
//                     ],
//                   ),

//                   child: ElevatedButton(
//                     onPressed: saveMeasurements,

//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,

//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),

//                     child: const Text(
//                       "Continue",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               /// LOADING
//               if (isLoading)
//                 Container(
//                   color: Colors.black.withOpacity(0.5),

//                   child: const Center(
//                     child: CircularProgressIndicator(color: Color(0xFF22C55E)),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// CARD
//   Widget _measurementCard({
//     required String title,
//     required IconData icon,
//     required Color iconColor,
//     required TextEditingController controller,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(25),

//       decoration: BoxDecoration(
//         color: const Color(0xFF13213A).withOpacity(0.95),

//         borderRadius: BorderRadius.circular(28),

//         border: Border.all(color: Colors.white.withOpacity(0.06)),
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Color(0xFF94A3B8),
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 25),

//           Row(
//             children: [
//               Icon(icon, color: iconColor, size: 34),

//               const SizedBox(width: 18),

//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   keyboardType: TextInputType.number,

//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.w500,
//                   ),

//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "0",

//                     hintStyle: TextStyle(color: Colors.white54),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// PROGRESS
//   Widget _progress(bool active) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),

//       margin: const EdgeInsets.symmetric(horizontal: 6),

//       width: active ? 62 : 46,
//       height: 8,

//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),

//         gradient: active
//             ? const LinearGradient(
//                 colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
//               )
//             : null,

//         color: active ? null : const Color(0xFF253247),
//       ),
//     );
//   }
// }
