import 'package:fitmind_ai/controller/profile_controller.dart';
import 'package:fitmind_ai/view/buttom_bar.dart';
import 'package:fitmind_ai/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Set up your profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Help us personalize your experience",
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),

              const SizedBox(height: 30),

              // Name
              _buildField("Name", controller.nameController, Icons.person),

              const SizedBox(height: 20),

              // Age
             
              _buildField(
                "Age",
                controller.ageController,
                Icons.calendar_today,
                isNumber: true,
              ),

              const SizedBox(height: 20),

              // Weight & Height
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      "Weight (kg)",
                      controller.weightController,
                      Icons.monitor_weight,
                      isNumber: true,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildField(
                      "Height (cm)",
                      controller.heightController,
                      Icons.height,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Goal Title
              const Text(
                "Fitness Goal",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Goal Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _goalCard(context, "Lose", "Lose", "Lose Weight", controller),

                  _goalCard(
                    context,
                    "Maintain",
                    "Maintain",
                    "Stay Balanced",
                    controller,
                  ),

                  _goalCard(
                    context,
                    "Gain",
                    "Gain",
                    "Build Muscle",
                    controller,
                  ),
                ],
              ),

              const SizedBox(height: 100),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 66,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  onPressed: () {
                    if (controller.validate()) {
                      final user = controller.getUserData();

                      showCustomSnackBar(
                        context,
                        "Profile Saved Successfully 🎉",
                        true,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainView(),
                        ),
                      );
                    } else {
                      showCustomSnackBar(
                        context,
                        "Please fill all fields ❗",
                        false,
                      );
                    }
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Continue ",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field (Dark)
 Widget _buildField(
  String title,
  TextEditingController controller,
  IconData icon, {
  bool isNumber = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      // Title (Bold)
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      const SizedBox(height: 5),

      // TextField
      TextField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : TextInputType.text,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),

        decoration: InputDecoration(

          prefixIcon: Icon(icon, color: Colors.grey),

          hintText: title,
          hintStyle: const TextStyle(color: Colors.grey),

          filled: true,
          fillColor: const Color(0xFF1A1A1A),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
  // Goal Card (Dark)
  Widget _goalCard(
    BuildContext context,
    String value,
    String title,
    String subtitle,
    ProfileController controller,
  ) {
    bool selected = controller.selectedGoal == value;

    // Select icon based on goal
    IconData goalIcon;

    switch (value) {
      case "Lose":
        goalIcon = Icons.trending_down; // Weight Loss
        break;

      case "Maintain":
        goalIcon = Icons.balance; // Balance
        break;

      case "Gain":
        goalIcon = Icons.trending_up; // Muscle Gain
        break;

      default:
        goalIcon = Icons.flag;
    }

    return GestureDetector(
      onTap: () => controller.selectGoal(value),

      child: Container(
        width: 110,
       
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: selected
              ? Colors.green.withOpacity(0.2)
              : const Color(0xFF1A1A1A),

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade700,
            width: 2,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              goalIcon,
              size: 38,
              color: selected ? Colors.green : Colors.grey,
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: selected ? Colors.green : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: selected ? Colors.green : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomSnackBar(BuildContext context, String message, bool isSuccess) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,

    content: Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),

        gradient: LinearGradient(
          colors: isSuccess
              ? [Colors.green, Colors.teal]
              : [Colors.red, Colors.orange],
        ),
      ),

      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
