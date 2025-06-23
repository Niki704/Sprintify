import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Getting Started",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "• Tap the '+' or 'Start Practice' button on the home screen to begin a new session.\n"
                "• After finishing, your session will be saved and appear in your Achievements.\n"
                "• Visit the Achievements section to view, share, or review your completed sessions.\n"
                "• Use Settings to switch units, enable notifications, or clear your data.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 28),
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          _FAQEntry(
            question: "How do I start a new event or session?",
            answer: "Press the '+' button or 'Start Practice' on the main screen. Fill in the required details and begin tracking.",
          ),
          _FAQEntry(
            question: "How can I view or share my past sessions?",
            answer: "Go to the Achievements section. Select any session to view details or use the Share button to share with friends.",
          ),
          _FAQEntry(
            question: "How do I change distance units (meters/miles)?",
            answer: "Open the Settings screen and choose your preferred unit under 'Units'.",
          ),
          _FAQEntry(
            question: "How do I clear my practice history?",
            answer: "In Settings, tap 'Clear All History'. Confirm to permanently erase all your session data.",
          ),
          _FAQEntry(
            question: "What if I need help or find a bug?",
            answer: "Contact the developer or support team using the info below.",
          ),
          const SizedBox(height: 28),
          const Text(
            "Contact & Feedback",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.email, color: Colors.deepPurple),
            title: Text("Email"),
            subtitle: Text("support@sprintify.com"),
          ),
          const ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text("Developer"),
            subtitle: Text("Niki704"),
          ),
          const ListTile(
            leading: Icon(Icons.code, color: Colors.deepPurple),
            title: Text("GitHub"),
            subtitle: Text("github.com/Niki704/sprint_tracker"),
          ),
        ],
      ),
    );
  }
}

class _FAQEntry extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQEntry({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 12, right: 6, bottom: 12),
      title: Text(
        question,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        )
      ],
    );
  }
}