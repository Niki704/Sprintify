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
            "Welcome to Sprint Tracker! Here's how to get up and running:\n\n"
                "1. Create an Account: The first step is to sign up or log in. Your data is securely tied to your account.\n\n"
                "2. The Main Tabs: Use the bottom bar to navigate the app's features:\n"
                "   • Setup Race: Configure parameters for a new race.\n"
                "   • Start Race: Begin the race timer and record laps.\n"
                "   • Sprint Sessions: Review a detailed list of all past races.\n"
                "   • Statistics: View charts and data on your performance.\n"
                "   • Achievements: See milestones you've unlocked.\n"
                "   • Settings: Manage your profile, data, and log out.\n\n"
                "3. Run Your First Race: First, go to 'Setup Race' to define the distance and laps. Then, move to the 'Start Race' tab to begin. Press 'Lap' to record times and 'Finish' to save the session.\n\n"
                "4. Review Your Progress: Go to the 'Sprint Sessions' tab to see a list of your completed races. Tap 'Details' on any session to see a full breakdown of each lap.",
            style: TextStyle(fontSize: 16, height: 1.5),
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
            question: "How is my race data saved?",
            answer: "Your session is saved automatically when you press the 'Finish' button on the 'Start Race' screen. The data is stored online and linked to your user account.",
          ),
          _FAQEntry(
            question: "What information is shown in the session details?",
            answer: "The details dialog shows you the total number of laps and the distance per lap. It also provides a full breakdown of each lap's time and average speed.",
          ),
          _FAQEntry(
            question: "How do I manage my profile information?",
            answer: "Navigate to the 'Settings' tab and tap on your user profile at the top. This will take you to a screen where you can manage your details.",
          ),
          _FAQEntry(
            question: "Can I recover data after deleting it?",
            answer: "No. Deleting a single session from the 'Sprint Sessions' screen or using 'Clear All History' in Settings is a permanent action and cannot be undone.",
          ),
          _FAQEntry(
            question: "Why are some settings or tabs empty?",
            answer: "Features like Statistics, Achievements, and Dark Mode are currently in development and will be enabled in a future update.",
          ),
          _FAQEntry(
            question: "What happens when I log out?",
            answer: "Logging out securely signs you out of your account. You will need to log back in to access your race history and profile information.",
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