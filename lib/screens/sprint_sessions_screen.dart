import 'package:flutter/material.dart';
import 'dart:math'; // Imported for generating random data

class SprintSessionsScreen extends StatefulWidget {
  const SprintSessionsScreen({Key? key}) : super(key: key);

  @override
  State<SprintSessionsScreen> createState() => _SprintSessionsScreenState();
}

class _SprintSessionsScreenState extends State<SprintSessionsScreen> {
  // --- DYNAMIC LAP CONTROL ---
  // You can change this value to control the number of laps.
  // This simulates fetching the lap count from a database.
  final int totalLaps = 5;

  // This list will be populated dynamically based on totalLaps.
  late List<Map<String, dynamic>> _laps;
  int _activeLap = 1;

  bool reverseDirection = false;

  @override
  void initState() {
    super.initState();
    _generateLapData();
  }

  /// Generates sample lap data based on the `totalLaps` variable.
  void _generateLapData() {
    _laps = [];
    final random = Random();
    // For demonstration, let's assume some laps are completed.
    // Here, we'll mark all but the last two as completed.
    final completedLaps = max(0, totalLaps - 2);
    _activeLap = completedLaps + 1;

    for (int i = 0; i < totalLaps; i++) {
      if (i < completedLaps) {
        // Generate data for a completed lap
        _laps.add({
          'completed': true,
          'time': '${random.nextInt(15) + 10} sec', // e.g., 10-24 sec
          'speed': '${random.nextInt(5) + 20} m/s', // e.g., 20-24 m/s
          'distance': '1000.0 m',
        });
      } else {
        // Data for an incomplete or active lap
        _laps.add({
          'completed': false,
          'time': null,
          'speed': null,
          'distance': null,
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sprint Sessions',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        color: const Color(0xFFF4F5FA),
        child: Column(
          children: [
            const SizedBox(height: 22),
            // --- DYNAMIC "ACTIVE LAP" TEXT ---
            Text.rich(
              TextSpan(
                text: 'Active Lap: ',
                style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600
                ),
                children: [
                  TextSpan(
                    text: '$_activeLap / $totalLaps', // Now uses dynamic values
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reverse Direction",
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Switch(
                    value: reverseDirection,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) {
                      setState(() {
                        reverseDirection = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // --- DYNAMIC LISTVIEW ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: _laps.length, // Uses the length of the generated list
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final lap = _laps[i];
                  return SprintLapCard(
                    lapNumber: i + 1,
                    completed: lap['completed'] as bool,
                    time: lap['time'] as String?,
                    speed: lap['speed'] as String?,
                    distance: lap['distance'] as String?,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SprintLapCard extends StatelessWidget {
  final int lapNumber;
  final bool completed;
  final String? time;
  final String? speed;
  final String? distance;

  const SprintLapCard({
    super.key,
    required this.lapNumber,
    required this.completed,
    this.time,
    this.speed,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the styling based on whether the lap is active or completed.
    // The first incomplete lap is considered 'active'.
    final isCompleted = completed;
    final isActive = !isCompleted && (context.findAncestorStateOfType<_SprintSessionsScreenState>()?._activeLap == lapNumber);

    Color accent;
    if (isCompleted) {
      accent = Colors.green;
    } else if (isActive) {
      accent = Colors.orange;
    } else {
      accent = Colors.grey;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: accent.withOpacity(0.15),
              child: Text(
                lapNumber.toString(),
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Lap details
            Expanded(
              child: isCompleted
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finished in $time',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.deepPurple, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        speed ?? '-',
                        style: const TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                        ),
                      ),
                      const SizedBox(width: 18),
                      Icon(Icons.straighten, color: Colors.blue, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        distance ?? '-',
                        style: const TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Lap in progress...' : 'Waiting for data...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isActive ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    isActive ? 'Complete the lap to see results' : 'Lap not completed yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'NunitoSans',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}