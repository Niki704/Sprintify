import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example session data
    final events = [
      {
        'id': '25f12nSJEIXueO44GNWk',
        'distance': 1000.0,
        'laps': 2,
        'date': DateTime(2025, 6, 22),
      },
      {
        'id': '6p9LnSSSrXAk7Blg9cGl',
        'distance': 1000.0,
        'laps': 2,
        'date': DateTime(2025, 6, 22),
      },
      {
        'id': 'lOwz4g0pVTgT6eUUSA7N',
        'distance': 1000.0,
        'laps': 2,
        'date': DateTime(2025, 6, 22),
      },
      {
        'id': 'fQ6tnLsT8XzpwlK7zOX7',
        'distance': 1000.0,
        'laps': 2,
        'date': DateTime(2025, 6, 22),
      },
      {
        'id': 'LZF0vQwT8a9CBbhIf8AR',
        'distance': 1000.0,
        'laps': 2,
        'date': DateTime(2025, 6, 22),
      },
    ];

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
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final event = events[i];
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

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: _getAccentColor(index),
            width: 8,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        leading: CircleAvatar(
          backgroundColor: _getAccentColor(index).withOpacity(0.15),
          radius: 26,
          child: Icon(
            Icons.emoji_events,
            color: _getAccentColor(index),
            size: 28,
          ),
        ),
        title: Text(
          "Session #${index + 1}",
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Practice ID: $id",
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 13.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Distance: ${distance.toStringAsFixed(1)} m | Laps: $laps",
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontSize: 13.5,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.search, size: 18),
              label: const Text("Details"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: Details action
              },
            ),
            const SizedBox(height: 7),
            OutlinedButton.icon(
              icon: const Icon(Icons.share, size: 17),
              label: const Text("Share"),
              style: OutlinedButton.styleFrom(
                foregroundColor: _getAccentColor(index),
                side: BorderSide(color: _getAccentColor(index)),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                // TODO: Share action
              },
            ),
          ],
        ),
      ),
    );
  }

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
}