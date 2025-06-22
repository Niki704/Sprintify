import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprintify'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {}, // TODO: open drawer or menu
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/athlete.jpg', // Replace with your image asset or network image
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Profile Section
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'your.email@example.com',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Practice Summary Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const Text(
                      "Practice Summary",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _SummaryItem(
                          icon: Icons.fitness_center,
                          label: "Sessions",
                          value: "19",
                        ),
                        _SummaryItem(
                          icon: Icons.directions_run,
                          label: "Laps",
                          value: "46",
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _SummaryItem(
                          icon: Icons.show_chart,
                          label: "Avg Lap",
                          value: "921.74 m",
                        ),
                        _SummaryItem(
                          icon: Icons.calendar_today,
                          label: "Latest",
                          value: "22/6/2025",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Motivational Text
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Ready to break your limits today?",
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start Practice"),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text("Practice History"),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sports_gymnastics),
                label: const Text("Practice Modes"),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget for summary items
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}