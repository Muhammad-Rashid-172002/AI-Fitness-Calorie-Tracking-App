import 'package:flutter/material.dart';

class QuickStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Colors based on your UI theme
  //  const Color cardBg = Color(0xFF1E2623); // Dark grayish-green
    const Color accentGreen = Color(0xFF4ADE80); // Bright green
    const Color textSecondary = Colors.white70;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Quick Stats",
            style: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          children: [
            // Card 1: Current Weight
            _buildStatCard(
              label: "Current Weight",
              value: "90 kg",
              subtext: "↓ -1.2 kg",
              subtextColor: accentGreen,
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(width: 10),
            
            // Card 2: Weekly Score
            _buildStatCard(
              label: "Weekly Score",
              value: "82",
              isProgress: true,
              progressValue: 0.82,
              icon: Icons.description_outlined,
            ),
            const SizedBox(width: 10),
            
            // Card 3: Streak
            _buildStatCard(
              label: "Streak",
              value: "5 Days",
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to create equal sized cards
  Widget _buildStatCard({
    required String label,
    required String value,
    String? subtext,
    Color? subtextColor,
    required IconData icon,
    Color iconColor = Colors.white54,
    bool isProgress = false,
    double progressValue = 0.0,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2623),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (isProgress)
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.white10,
                color: const Color(0xFF4ADE80),
                minHeight: 3,
              )
            else if (subtext != null)
              Text(
                subtext,
                style: TextStyle(color: subtextColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}