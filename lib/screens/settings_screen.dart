import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart'; // Import the new profile screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  User? _user;
  String? _userName;
  bool _isProfileLoading = true;

  final bool isDarkMode = false; // Kept for UI state

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _user = _auth.currentUser;
    if (_user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'];
          });
        }
      } catch (e) {
        // Handle error
      }
    }
    setState(() {
      _isProfileLoading = false;
    });
  }

  // --- FIX: Implement Logout Confirmation Dialog ---
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              FirebaseAuth.instance.signOut(); // Sign out the user
              // The StreamBuilder in main.dart will automatically handle navigation
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllHistory() async {
    final bool? confirmClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text("Confirm Clear History", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to permanently delete all session data? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF2e2e2e))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // --- STYLE FIX: Destructive actions should be red ---
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Clear Data'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmClear == true && _user != null) {
      try {
        final sessionsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('sessions');

        final snapshot = await sessionsRef.get();

        final batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All session history has been cleared."), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing history: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

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
          _isProfileLoading
              ? const ListTile(
            leading: CircleAvatar(radius: 24),
            title: Text("Loading..."),
          )
              : ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: Text(
                (_userName != null && _userName!.isNotEmpty)
                    ? _userName!.substring(0, 1).toUpperCase()
                    : 'U',
              ),
              radius: 24,
            ),
            title: Text(_userName ?? "User"),
            subtitle: Text(_user?.email ?? "No email provided"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Display", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.nightlight_round),
            title: const Text("Dark Mode"),
            subtitle: const Text("Coming soon"),
            value: isDarkMode,
            onChanged: null,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Race Defaults", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.replay_circle_filled_outlined),
            title: Text("Default Lap Count"),
            subtitle: Text("10 Laps"),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.straighten_outlined),
            title: Text("Default Distance Per Lap"),
            subtitle: Text("1000m"),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Account", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About & Help"),
            onTap: () => _showHelpDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Clear All History"),
            onTap: _clearAllHistory,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out"),
            // --- FIX: Call the confirmation dialog on tap ---
            onTap: _showLogoutConfirmationDialog,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Sprint Tracker",
      applicationVersion: "v1.0.0",
      applicationIcon: const Icon(Icons.flag, size: 32, color: Colors.deepPurple),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "• Track and review your practice sessions.\n"
                "• View statistics and achievements.\n"
                "• Customize your experience in settings.\n\n"
                "For more help or feedback, contact: support@sprintify.com",
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}