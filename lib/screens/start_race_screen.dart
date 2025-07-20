import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'sprint_sessions_screen.dart';
import 'dashboard_screen.dart';

// --- ADDED: Firebase Database URL ---
const String databaseUrl = 'https://sprint-tracker-sys-default-rtdb.asia-southeast1.firebasedatabase.app';

class StartRaceScreen extends StatefulWidget {
  const StartRaceScreen({super.key});

  @override
  State<StartRaceScreen> createState() => _StartRaceScreenState();
}

class _StartRaceScreenState extends State<StartRaceScreen> {
  // --- MODIFIED: State variables to hold data from Firebase ---
  late final DatabaseReference _sessionRef;
  StreamSubscription<DatabaseEvent>? _sessionSubscription;

  int _lapCount = 0;
  int _lapDistance = 0;
  String _status = 'NOT_CONFIGURED';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // --- ADDED: Initialize and listen to Firebase ---
    _sessionRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref('current_sprint_session');

    _sessionSubscription = _sessionRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _lapCount = data['lapCount'] ?? 0;
          _lapDistance = data['distancePerLap'] ?? 0;
          _status = data['status'] ?? 'NOT_CONFIGURED';
        });
      } else {
        setState(() {
          _lapCount = 0;
          _lapDistance = 0;
          _status = 'NOT_CONFIGURED';
        });
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  // --- MODIFIED: Renamed and updated to change status in Firebase ---
  Future<void> _confirmDevicePlacement() async {
    setState(() => _isLoading = true);
    try {
      await _sessionRef.update({'status': 'DEVICE_READY'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device placement confirmed! Ready to start.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MODIFIED: Replaced with a new function to start the race ---
  Future<void> _startRace() async {
    setState(() => _isLoading = true);
    try {
      await _sessionRef.update({'status': 'RACE_IN_PROGRESS'});
      if (mounted) {
        _showRaceStartedDialog();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start race: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MODIFIED: Dialog box is updated to the new style ---
  void _showRaceStartedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text("Race Started!", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Track your progress in Sprint Sessions or exit to the dashboard."),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2e2e2e)),
              child: const Text('Exit to Dashboard'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sprint Sessions'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SprintSessionsScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- ADDED: Logic to control button states ---
    final bool isConfigured = _lapCount > 0 && _lapDistance > 0;
    final bool canConfirmPlacement = isConfigured && _status == 'SETUP_COMPLETE';
    final bool canStartRace = isConfigured && _status == 'DEVICE_READY';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Race', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
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
                      // --- MODIFIED: Use state variables ---
                      _buildDetailRow('Lap Count:', '$_lapCount Laps'),
                      const SizedBox(height: 16),
                      _buildDetailRow('Lap Distance:', '$_lapDistance m'),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.flag, size: 18),
                  label: const Text("Start Race"),
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
                  // --- MODIFIED: Use new state logic ---
                  onPressed: canStartRace && !_isLoading ? _startRace : null,
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2e2e2e),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2e2e2e).withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  // --- MODIFIED: Use new state logic ---
                  onPressed: canConfirmPlacement && !_isLoading ? _confirmDevicePlacement : null,
                  child: const Text("Confirm Device Placement", style: TextStyle(fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // --- ADDED: Loading indicator ---
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontFamily: 'NunitoSans'),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
      ],
    );
  }
}