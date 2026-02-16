import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

    appBar: AppBar(
  backgroundColor: Colors.black,
  elevation: 0,
  toolbarHeight: 90,

  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 18),
      // Greeting
      Text(
        _getGreeting(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
      ),

      const SizedBox(height: 4),

      // Name
      const Text(
        "Rashid",
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),

     

     
    ],
  ),
),

body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10, right: 16),

        child: Column(
          children: [
            SizedBox(height: 20),
            // Calories Card
            _caloriesCard(),

            const SizedBox(height: 20),

            // Scan Button
            _scanButton(),

            const SizedBox(height: 20),

            // Macros Card
            _macrosCard(),

            const SizedBox(height: 20),

            // Daily Tip
            _dailyTipCard(),
          ],
        ),
      ),
    );
  }

  // Calories Progress Card
  Widget _caloriesCard() {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          // Left Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              Text(
                "Today's \nCalories",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "2426",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "remaining",
                style: TextStyle(color: Colors.white70, fontSize: 19),
              ),

              SizedBox(height: 10),

              Row(
                children: [

                  Icon(Icons.restaurant,
                      color: Colors.white70, size: 22),

                  SizedBox(width: 5),

                  Text(
                    "0 meals \nlogged",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [

              SizedBox(
                width: 200,
                height: 200,

                child: CircularProgressIndicator(
                  value: 0.0,
                  strokeWidth: 14,
                  backgroundColor: Colors.white,
                  valueColor:
                      const AlwaysStoppedAnimation(Colors.white),
                ),
              ),

              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    "0",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "of 2426 kcal",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Scan Meal Button
  Widget _scanButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,

      child: ElevatedButton.icon(
        onPressed: () {},

        icon: const Icon(Icons.camera_alt, color: Colors.white,size: 25,),

        label: const Text(
          "Scan a Meal",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // Macros Card
  Widget _macrosCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Macros",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        _macroRow("Protein", 45, 120),
        _macroRow("Carbs", 80, 200),
        _macroRow("Fat", 30, 70),
      ],
    ),
  );
}
  
  // Macro Row
 Widget _macroRow(String title, double value, double max) {
  double progress = value / max;

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Title + Numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            Text(
              "${value.toInt()}g / ${max.toInt()}g",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation(
              _getMacroColor(title),
            ),
          ),
        ),
      ],
    ),
  );
}

Color _getMacroColor(String title) {
  switch (title) {
    case "Protein":
      return Colors.green;
    case "Carbs":
      return Colors.orange;
    case "Fat":
      return Colors.red;
    default:
      return Colors.blue;
  }
}
  // Daily Tip Card
  Widget _dailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF10231B),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: const [

          Icon(Icons.eco, color: Colors.green),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "DAILY TIP",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Add more greens to your meals",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
String _getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return "Good Morning ☀️";
  } else if (hour < 17) {
    return "Good Afternoon 🌤️";
  } else {
    return "Good Evening 🌙";
  }
}