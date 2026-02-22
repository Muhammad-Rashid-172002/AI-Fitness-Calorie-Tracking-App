import 'package:fitmind_ai/services/StripePaymentProvider.dart';
import 'package:fitmind_ai/view/Premium_Screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StripePaymentProvider>(
        builder: (context, stripeProvider, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF0B1120),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: Stack(
              children: [
                /// Green Glow Top
                Positioned(
                  top: -100,
                  left: -80,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.green, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                /// Green Glow Bottom
                Positioned(
                  bottom: -120,
                  right: -80,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.green, Colors.transparent],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        /// Title
                        const Text(
                          "Select Payment",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Choose how you'd like to pay.",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 40),

                        paymentTile(
                          0,
                          Icons.credit_card,
                          "Credit / Debit Card",
                        ),
                        //  paymentTile(1, Icons.phone_iphone, "Apple Pay"),
                        paymentTile(2, Icons.android, "Google Pay"),
                        paymentTile(3, Icons.account_balance_wallet, "Wallet"),

                        const Spacer(),

                        /// Proceed Button (custom gradient style)
                        SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: ElevatedButton(
                            onPressed: selectedIndex == -1
                                ? null
                                : () async {
                                    try {
                                      // Stripe Payment Direct Open
                                      await context
                                          .read<StripePaymentProvider>()
                                          .makePayment(isReActivation: false);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Payment Successful 🎉",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Payment Failed ❌"),
                                        ),
                                      );
                                    }
                                  },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.disabled,
                                    )) {
                                      return Colors.white24;
                                    }
                                    return null;
                                  }),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 0),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(10),
                              shadowColor: MaterialStateProperty.all(
                                Colors.green.withOpacity(0.45),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: selectedIndex == -1
                                    ? const LinearGradient(
                                        colors: [
                                          Colors.white24,
                                          Colors.white24,
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF22C55E),
                                          Color(0xFF06B6D4),
                                          Color(0xFF38BDF8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Proceed",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Selectable Payment Tile
  Widget paymentTile(int index, IconData icon, String title) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.green : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
