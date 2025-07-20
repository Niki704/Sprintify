import 'package:flutter/material.dart';
import 'sprint_sessions_screen.dart';
import 'dashboard_screen.dart'; // Import the dashboard screen

/// A screen to start a pre-configured race.
class StartRaceScreen extends StatefulWidget {
  const StartRaceScreen({super.key});

  @override
  State<StartRaceScreen> createState() => _StartRaceScreenState();
}

class _StartRaceScreenState extends State<StartRaceScreen> {
  // Hardcoded values for demonstration purposes.
  final int lapCount = 5;
  final int lapDistance = 400;

  // State variable to track if the status has been checked.
  bool _isStatusChecked = false;

  /// Handles the logic for checking the race status.
  void _checkStatus() {
    setState(() {
      _isStatusChecked = true;
    });
    // TODO: Implement actual status check logic
    print('The application has moved to the ready state!');
    // Optionally, show a confirmation to the user.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status checked! You can now start the race.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows the dialog when the race starts.
  void _showStartRaceDialog() {
    showDialog(
      context: context,
      // Prevents closing the dialog by tapping outside of it
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Apply Montserrat font to the title
          title: const Text(
            "Race has started !",
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
          ),
          // Apply NunitoSans font to the content
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Press 'Sprint Sessions' to track your progress.",
                style: TextStyle(fontFamily: 'NunitoSans'),
              ),
              SizedBox(height: 8),
              Text(
                "Press 'Exit' to go to the main menu.",
                style: TextStyle(fontFamily: 'NunitoSans'),
              ),
            ],
          ),
          // Align actions to distribute space between them
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            // "Check Progress" button with deepPurple color
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text('Sprint Sessions'),
              onPressed: () {
                // TODO: Implement navigation to a progress tracking screen
                Navigator.of(dialogContext).pop();  // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SprintSessionsScreen()),
                );
              },
            ),
            // "Exit" button with custom dark color
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2e2e2e),
              ),
              child: const Text('Exit'),
              onPressed: () {
                // First, pop the dialog.
                Navigator.of(dialogContext).pop();
                // Then, navigate to the Dashboard screen, replacing the current screen.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Handles the logic for starting the race.
  void _startRace() {
    // TODO: Implement actual race start logic
    _showStartRaceDialog();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Race started!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with the consistent theme
      appBar: AppBar(
        title: const Text(
          'Start Race',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      // Background color consistent with the theme
      backgroundColor: const Color(0xFFF4F5FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display container for race details
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Lap Count:', '$lapCount Laps'),
                  const SizedBox(height: 16),
                  // Display lapDistance with "m" for meters
                  _buildDetailRow('Lap Distance:', '$lapDistance m'),
                ],
              ),
            ),
            const SizedBox(height: 40.0), // Spacer

            // "Start Race" button is disabled until status is checked
            ElevatedButton.icon(
              icon: const Icon(Icons.flag, size: 18),
              label: const Text("Start Race"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
                disabledForegroundColor: Colors.white.withOpacity(0.7),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              onPressed: _isStatusChecked ? _startRace : null,
            ),
            const SizedBox(height: 12.0), // Spacer between buttons

            // "Checked Distance Status" button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e2e2e),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF2e2e2e).withOpacity(0.5),
                disabledForegroundColor: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              // Button is disabled once status is checked
              onPressed: _isStatusChecked ? null : _checkStatus,
              child: const Text(
                "Checked Distance Status",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to create a consistent row for displaying details.
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.deepPurple,
            fontFamily: 'NunitoSans',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}