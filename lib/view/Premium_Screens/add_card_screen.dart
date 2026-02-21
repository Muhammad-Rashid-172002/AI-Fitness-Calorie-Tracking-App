// import 'package:fitmind_ai/resources/custom_gradient_button.dart';
// import 'package:fitmind_ai/services/StripePaymentProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AddCardScreen extends StatefulWidget {
//   const AddCardScreen({super.key});

//   @override
//   State<AddCardScreen> createState() => _AddCardScreenState();
// }

// class _AddCardScreenState extends State<AddCardScreen> {
//   bool saveCard = false;

//   final TextEditingController cardNumber = TextEditingController();
//   final TextEditingController cardHolder = TextEditingController();
//   final TextEditingController expiry = TextEditingController();
//   final TextEditingController cvv = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<StripePaymentProvider>(
//         builder: (context, stripeProvider, child) {
//           return Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF0F172A), Color(0xFF0B1120), Colors.black],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 /// Green Glow Top
//                 Positioned(
//                   top: -100,
//                   left: -80,
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [Colors.green, Colors.transparent],
//                       ),
//                     ),
//                   ),
//                 ),

//                 /// Green Glow Bottom
//                 Positioned(
//                   bottom: -120,
//                   right: -80,
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: RadialGradient(
//                         colors: [Colors.green, Colors.transparent],
//                       ),
//                     ),
//                   ),
//                 ),

//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: ListView(
//                       children: [
//                         const SizedBox(height: 20),

//                         /// Back + Lock icon
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(
//                                 Icons.arrow_back_ios,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                             const Icon(Icons.lock_outline, color: Colors.white70),
//                           ],
//                         ),

//                         const SizedBox(height: 30),

//                         /// Title
//                         const Text(
//                           "Add Card",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 5),

//                         const Text(
//                           "Secure SSL Connection.",
//                           style: TextStyle(color: Colors.white70),
//                         ),

//                         const SizedBox(height: 30),

//                         /// Card Number
//                         inputField(
//                           label: "Card Number",
//                           hint: "0000 0000 0000 0000",
//                           controller: cardNumber,
//                           icon: Icons.credit_card,
//                         ),

//                         const SizedBox(height: 20),

//                         /// Card Holder
//                         inputField(
//                           label: "Card Holder",
//                           hint: "John Doe",
//                           controller: cardHolder,
//                           icon: Icons.person_outline,
//                         ),

//                         const SizedBox(height: 20),

//                         /// Expiry + CVV
//                         Row(
//                           children: [
//                             Expanded(
//                               child: inputField(
//                                 label: "Expiry",
//                                 hint: "MM/YY",
//                                 controller: expiry,
//                                 icon: Icons.calendar_month,
//                               ),
//                             ),
//                             const SizedBox(width: 15),
//                             Expanded(
//                               child: inputField(
//                                 label: "CVV",
//                                 hint: "123",
//                                 controller: cvv,
//                                 icon: Icons.lock_outline,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 25),

//                         /// Save Card Switch
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "Save card for future",
//                               style: TextStyle(color: Colors.white70),
//                             ),
//                             Switch(
//                               value: saveCard,
//                               activeColor: Colors.green,
//                               onChanged: (v) {
//                                 setState(() => saveCard = v);
//                               },
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 40),

//                         /// Pay Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 62,
//                           child: CustomGradientButton(
//                             text: 'Pay & Start Trial',
//                             onPressed: () async {
//                               try {
//                                 // Example: yearly payment amount in cents
//                                 int amount = 5999; // $59.99
//                                 await stripeProvider.makePayment(
//                                //  await stripeProvider.makePayment();
//                                 );

//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("Payment Successful 🎉"),
//                                   ),
//                                 );

//                                 // TODO: Save premium status in DB
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text("Payment Failed ❌\n$e"),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// Input Field Widget
//   Widget inputField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white70)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: Colors.white70),
//             hintText: hint,
//             hintStyle: const TextStyle(color: Colors.white38),
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.05),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(25),
//               borderSide: const BorderSide(color: Colors.white24),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(25),
//               borderSide: const BorderSide(color: Colors.white24),
//             ),
//           ),
//           keyboardType: label == "Card Number" || label == "CVV"
//               ? TextInputType.number
//               : TextInputType.text,
//         ),
//       ],
//     );
//   }
// }

import 'package:fitmind_ai/services/StripePaymentProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({super.key});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StripePaymentProvider>(
        builder: (context, value, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () async {
                      await value.makePayment();
                    },
                    child: const Text('Pay Now!!'))
              ],
            ),
          );
        },
      ),
    );
  }
}
