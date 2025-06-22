import 'package:flutter/material.dart';

class SprintSessionsScreen extends StatefulWidget {
  const SprintSessionsScreen({Key? key}) : super(key: key);

  @override
  State<SprintSessionsScreen> createState() => _SprintSessionsScreenState();
}

class _SprintSessionsScreenState extends State<SprintSessionsScreen> {
  bool reverseDirection = false;

  // sample lap data
  final laps = [
    {
      'completed': true,
      'time': '12 sec',
      'speed': '22 m/s',
      'distance': '1000.0 m'
    },
    {
      'completed': false,
      'time': null,
      'speed': null,
      'distance': null
    }
  ];

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
                    text: '2 / 2',
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: laps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final lap = laps[i];
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
    Key? key,
    required this.lapNumber,
    required this.completed,
    this.time,
    this.speed,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = completed ? Colors.green : Colors.orange;
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
              child: completed
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
                children: const [
                  Text(
                    'Waiting for data...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Lap not completed yet',
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