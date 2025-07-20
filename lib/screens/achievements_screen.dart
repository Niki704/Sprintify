import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late List<Map<String, dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _generateDummyEvents();
  }

  /// Generates a list of dummy event data to simulate fetching from a database.
  void _generateDummyEvents() {
    final random = Random();
    const ids = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    _events = List.generate(12, (index) {
      // Generate a random ID
      final id = String.fromCharCodes(Iterable.generate(
          20, (_) => ids.codeUnitAt(random.nextInt(ids.length))));
      return {
        'id': id,
        'distance': 1000.0,
        'laps': random.nextInt(8) + 2, // 2 to 9 laps
        // Generate dates within the last 60 days
        'date': DateTime.now().subtract(Duration(days: random.nextInt(60))),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        color: const Color(0xFFF7F7FA),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: _events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final event = _events[i];
            return _AchievementTile(
              index: i,
              id: event['id'] as String,
              distance: event['distance'] as double,
              laps: event['laps'] as int,
              date: event['date'] as DateTime,
            );
          },
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final int index;
  final String id;
  final double distance;
  final int laps;
  final DateTime date;

  const _AchievementTile({
    required this.index,
    required this.id,
    required this.distance,
    required this.laps,
    required this.date,
  });

  Color _getAccentColor(int i) {
    const colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.pink,
      Colors.teal,
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(date);
    final accentColor = _getAccentColor(index);

    return Card(
      elevation: 2,
      shadowColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left color bar
            Container(
              width: 10,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Session #${index + 1}",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Practice ID with overflow handling
                    Text(
                      "Practice ID: $id",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 13.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Distance: ${distance.toStringAsFixed(1)} m | Laps: $laps",
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 13.5,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Date: $formattedDate",
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 13.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: accentColor, // Set button color to the tile's accent color
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () { /* TODO: Details action */ },
                    child: const Text(
                      "Details",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // --- DELETE BUTTON ---
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () { /* TODO: Delete action */ },
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
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