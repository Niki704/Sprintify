import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String units = "Meters";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile-placeholder.png'),
              radius: 24,
            ),
            title: const Text("Your Name"),
            subtitle: const Text("View or edit profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              // Navigate to profile (implement if needed)
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.nightlight_round),
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (v) => setState(() => isDarkMode = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text("Units"),
            subtitle: Text(units),
            trailing: DropdownButton<String>(
              value: units,
              items: const [
                DropdownMenuItem(value: "Meters", child: Text("Meters")),
                DropdownMenuItem(value: "Miles", child: Text("Miles")),
              ],
              onChanged: (String? val) {
                if (val != null) setState(() => units = val);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About & Help"),
            onTap: () => _showHelpDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Clear All History"),
            onTap: () {
              // Implement clear history logic
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear All History"),
                  content: const Text("Are you sure you want to clear all data? This cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Actually clear data here
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("History cleared")),
                        );
                      },
                      child: const Text("Clear"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Speedify Sprint Tracker",
      applicationVersion: "v1.0",
      applicationIcon: const Icon(Icons.flag, size: 32, color: Colors.deepPurple),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "• Track and review your practice sessions.\n"
                "• View achievements and compare past events.\n"
                "• Customize units, notifications, and theme.\n\n"
                "For more help or feedback, contact: support@speedify.com",
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}