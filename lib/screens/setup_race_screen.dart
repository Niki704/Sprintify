import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

/// A screen for setting up a race with lap count and distance.
class SetupRaceScreen extends StatefulWidget {
  const SetupRaceScreen({super.key});

  @override
  State<SetupRaceScreen> createState() => _SetupRaceScreenState();
}

class _SetupRaceScreenState extends State<SetupRaceScreen> {
  // Controller to manage the text in the distance TextField.
  final _distanceController = TextEditingController();
  // Variable to hold the selected lap count from the dropdown.
  int? _selectedLapCount;

  @override
  void initState() {
    super.initState();
    // Add a listener to the text controller to rebuild the widget on text changes.
    _distanceController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // It's important to dispose of the controller when the widget is removed
    // from the widget tree to free up resources.
    _distanceController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    // Retrieve the values.
    final String lapCount = _selectedLapCount.toString();
    final String distance = _distanceController.text;

    // Here, you would typically handle the logic for the race setup.
    // For example, you might validate the input, save it, and navigate
    // to the next screen.
    //
    // For this example, we'll just print it to the console and show a dialog.
    print('Race setup confirmed:');
    print('Lap Count: $lapCount');
    print('Distance: $distance');

    // Show a confirmation dialog to the user.
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Race Confirmed'),
          content: Text('Laps: $lapCount\nDistance: $distance'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Pop up dialog box
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

  /// Resets the input fields to their initial state.
  void _resetValues() {
    setState(() {
      _selectedLapCount = null;
      _distanceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the button should be enabled.
    final bool isConfirmButtonEnabled =
        _selectedLapCount != null && _distanceController.text.isNotEmpty;

    return Scaffold(
      // Set the AppBar to match the SprintSessionsScreen theme
      appBar: AppBar(
        title: const Text(
          'Setup Race',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      // Set the background color to the solid light gray
      backgroundColor: const Color(0xFFF4F5FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Center the content vertically
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
              child: Text(
                'Lap Count',
                style: TextStyle(
                  color: Colors.black87, // Default label color
                  fontSize: 16,
                ),
              ),
            ),
            // Dropdown for Lap Count
            DropdownButtonFormField<int>(
              // Use a hint widget to show the placeholder text.
              hint: const Text('Select number of laps'),
              value: _selectedLapCount,
              menuMaxHeight: 250.0,
              items: List.generate(10, (index) => index + 1)
                  .map((lap) => DropdownMenuItem(
                value: lap,
                child: Text('$lap'),
              ))
                  .toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedLapCount = newValue;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Spacer

            // Text field for Distance
            TextField(
              controller: _distanceController,
              // Use default text style for dark theme
              decoration: InputDecoration(
                labelText: 'Distance',
                hintText: 'Enter the distance per lap (e.g., in meters)',
                // Use solid white fill for contrast
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
              // Use a number keyboard that allows decimals.
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32.0), // Spacer

            // Confirm Button
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 18),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                // Use a disabled color to give a visual cue to the user.
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
              // Disable button if either field is empty.
              onPressed: isConfirmButtonEnabled ? _onConfirm : null,
            ),
            const SizedBox(height: 12.0), // Spacer between buttons

            // Reset Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e2e2e),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _resetValues,
              child: const Text(
                "Reset",
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
}