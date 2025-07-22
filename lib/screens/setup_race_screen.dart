import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'start_race_screen.dart';
import 'dashboard_screen.dart';

const String databaseUrl = 'https://sprint-tracker-sys-default-rtdb.asia-southeast1.firebasedatabase.app';

/// A screen for setting up a race with lap count and distance.
class SetupRaceScreen extends StatefulWidget {
  const SetupRaceScreen({super.key});

  @override
  State<SetupRaceScreen> createState() => _SetupRaceScreenState();
}

class _SetupRaceScreenState extends State<SetupRaceScreen> {
  int? _selectedLapCount;
  int? _selectedDistance; // Changed from TextEditingController
  bool _isLoading = false;

  late final DatabaseReference _sessionRef;

  @override
  void initState() {
    super.initState();
    _sessionRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref('current_sprint_session');
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Saves the race configuration and shows a modern dialog.
  Future<void> _onConfirm() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to set up a race.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionData = {
        'lapCount': _selectedLapCount,
        'distancePerLap': _selectedDistance, // Use the selected distance
        'status': 'SETUP_COMPLETE',
      };
      await _sessionRef.set(sessionData);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            // --- MODIFIED DIALOG ---
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: const Text(
                'Setup Complete!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: const Text('Would you like to jump to the starting line?'),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Dashboard',
                    style: TextStyle(color: Color(0xFF2e2e2e)), // Set text color
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Set background color
                    foregroundColor: Colors.white, // Set foreground color
                  ),
                  child: const Text('Start Race'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const StartRaceScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send race setup: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Resets local values and clears the session data in the Realtime Database.
  Future<void> _resetValues() async {
    setState(() => _isLoading = true);
    try {
      // Clear the data in Firebase
      await _sessionRef.remove();
      // Reset local state
      setState(() {
        _selectedLapCount = null;
        _selectedDistance = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session has been reset.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset session: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Updated condition to check both dropdowns
    final bool isConfirmButtonEnabled =
        _selectedLapCount != null && _selectedDistance != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Race', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF4F5FA),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                  child: Text('Lap Count', style: TextStyle(color: Colors.black87, fontSize: 16)),
                ),
                DropdownButtonFormField<int>(
                  hint: const Text('Select number of laps'),
                  value: _selectedLapCount,
                  items: List.generate(10, (index) => index + 1)
                      .map((lap) => DropdownMenuItem(value: lap, child: Text('$lap Laps')))
                      .toList(),
                  onChanged: (int? newValue) => setState(() => _selectedLapCount = newValue),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                  child: Text('Distance Per Lap', style: TextStyle(color: Colors.black87, fontSize: 16)),
                ),
                // --- DISTANCE DROPDOWN ---
                DropdownButtonFormField<int>(
                  hint: const Text('Select distance in meters'),
                  value: _selectedDistance,
                  items: [100, 200, 400, 800, 1000]
                      .map((distance) => DropdownMenuItem(value: distance, child: Text('$distance m')))
                      .toList(),
                  onChanged: (int? newValue) => setState(() => _selectedDistance = newValue),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
                  ),
                ),
                if (_selectedDistance == 1000)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                    child: Text(
                      'Note: Reverse Direction mode will be automatically disabled for 1000m races.',
                      style: TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                    textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  onPressed: isConfirmButtonEnabled && !_isLoading ? _onConfirm : null,
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2e2e2e),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? _resetValues : _resetValues,
                  child: const Text("Reset", style: TextStyle(fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start, // This line is the fix
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Confirming new values will overwrite the previous setup. You can check the active settings on the Start Race.",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}