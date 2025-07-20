import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

const String databaseUrl = 'https://sprint-tracker-sys-default-rtdb.asia-southeast1.firebasedatabase.app';

class SprintSessionsScreen extends StatefulWidget {
  const SprintSessionsScreen({Key? key}) : super(key: key);

  @override
  State<SprintSessionsScreen> createState() => _SprintSessionsScreenState();
}

class _SprintSessionsScreenState extends State<SprintSessionsScreen> {
  late final DatabaseReference _sessionRef;
  StreamSubscription<DatabaseEvent>? _sessionSubscription;

  int _totalLaps = 0;
  int _distancePerLap = 0;
  String _status = 'NOT_CONFIGURED';
  List<Map<String, dynamic>> _laps = [];
  int _activeLap = 0;

  bool _isLapInProgress = false;
  int _expectedSensor = 1;

  bool reverseDirection = false;

  @override
  void initState() {
    super.initState();
    _sessionRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref('current_sprint_session');

    _sessionSubscription = _sessionRef.onValue.listen((DatabaseEvent event) {
      _processFirebaseData(event.snapshot);
    }, onError: (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listening to session data: $error')),
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  void _processFirebaseData(DataSnapshot snapshot) {
    if (!mounted) return;
    if (!snapshot.exists || snapshot.value == null) {
      setState(() {
        _totalLaps = 0;
        _laps = [];
        _activeLap = 0;
        _status = 'NOT_CONFIGURED';
      });
      return;
    }

    final sessionData = Map<String, dynamic>.from(snapshot.value as Map);
    _totalLaps = sessionData['lapCount'] ?? 0;
    _distancePerLap = sessionData['distancePerLap'] ?? 0;
    _status = sessionData['status'] ?? 'NOT_CONFIGURED';
    final lapsData = sessionData['laps'] as Map<dynamic, dynamic>? ?? {};

    final newLapsList = <Map<String, dynamic>>[];
    int newActiveLap = 0;
    bool lapInProgressFound = false;

    for (int i = 1; i <= _totalLaps; i++) {
      final lapKey = i.toString();
      final lap = lapsData[lapKey] as Map<dynamic, dynamic>?;

      if (lap != null && lap['startTime'] != null && lap['endTime'] != null) {
        final timeTakenMs = lap['endTime'] - lap['startTime'];
        final timeTakenSec = (timeTakenMs / 1000).toStringAsFixed(2);
        final speed = (_distancePerLap > 0 && timeTakenMs > 0) ? (_distancePerLap / (timeTakenMs / 1000)).toStringAsFixed(2) : '0.00';
        newLapsList.add({'completed': true, 'time': '$timeTakenSec sec', 'speed': '$speed m/s', 'distance': '$_distancePerLap m'});
      } else if (lap != null && lap['startTime'] != null) {
        lapInProgressFound = true;
        if (newActiveLap == 0) newActiveLap = i;
        newLapsList.add({'completed': false});
      } else {
        if (newActiveLap == 0) newActiveLap = i;
        newLapsList.add({'completed': false});
      }
    }

    if (newActiveLap > 0 && newLapsList.length == _totalLaps && newLapsList.every((l) => l['completed'] == true)) {
      newActiveLap = 0;
    }

    setState(() {
      _laps = newLapsList;
      _activeLap = newActiveLap;
      _isLapInProgress = lapInProgressFound;
      _updateExpectedSensor();
    });
  }

  void _updateExpectedSensor() {
    if (!reverseDirection) {
      _expectedSensor = _isLapInProgress ? 2 : 1;
    } else {
      bool isOddLap = _activeLap % 2 != 0;
      if (_isLapInProgress) {
        _expectedSensor = isOddLap ? 2 : 1;
      } else {
        _expectedSensor = isOddLap ? 1 : 2;
      }
    }
  }

  Future<void> _handleSensorTrigger(int sensorNumber) async {
    if (_activeLap == 0 || _activeLap > _totalLaps) return;

    if (sensorNumber != _expectedSensor) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wrong sensor! Waiting for Sensor $_expectedSensor.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final lapRef = _sessionRef.child('laps').child(_activeLap.toString());
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (_isLapInProgress) {
      await lapRef.update({'endTime': timestamp});
    } else {
      await lapRef.update({'startTime': timestamp});
    }
  }

  // --- ADDED: Function to handle the pull-to-refresh action ---
  Future<void> _handleRefresh() async {
    try {
      // Manually fetch the data once from Firebase
      final event = await _sessionRef.once();
      // Process the data just like the stream does
      _processFirebaseData(event.snapshot);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showSimulator = _status == 'RACE_IN_PROGRESS' && _activeLap > 0 && _activeLap <= _totalLaps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint Sessions', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (showSimulator)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.touch_app_outlined),
                tooltip: 'Open Simulator Controls',
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      endDrawer: showSimulator ? _buildSimulatorDrawer() : null,
      body: Container(
        color: const Color(0xFFF4F5FA),
        child: Column(
          children: [
            const SizedBox(height: 22),
            Text.rich(TextSpan(
              text: 'Active Lap: ',
              style: const TextStyle(fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              children: [
                TextSpan(
                  text: '${_activeLap > 0 && _activeLap <= _totalLaps ? _activeLap : '-'} / $_totalLaps',
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              ],
            )),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reverse Direction", style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w500, fontSize: 15)),
                  Switch(
                    value: reverseDirection,
                    activeColor: Colors.deepPurple,
                    onChanged: (_totalLaps == 0) ? null : (val) {
                      setState(() {
                        reverseDirection = val;
                        _updateExpectedSensor();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              // --- MODIFIED: Wrapped the list view with a RefreshIndicator ---
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Colors.deepPurple,
                child: _laps.isEmpty
                    ? Stack( // Wrap in a Stack to allow scrolling for the empty view
                  children: [
                    ListView(), // This makes the RefreshIndicator work when the list is empty
                    Center(child: _totalLaps > 0 ? const CircularProgressIndicator() : const Text("No race session is active.", style: TextStyle(fontSize: 16, color: Colors.grey))),
                  ],
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _laps.length,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatorDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFFF4F5FA),
        child: Column(
          children: [
            AppBar(
              title: const Text('Simulator Controls'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Waiting for trigger from:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sensor $_expectedSensor',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.touch_app),
                      label: const Text('Trigger Sensor 1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _expectedSensor == 1 ? Colors.green : Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _handleSensorTrigger(1),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.touch_app),
                      label: const Text('Trigger Sensor 2'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _expectedSensor == 2 ? Colors.green : Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _handleSensorTrigger(2),
                    ),
                  ],
                ),
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

  const SprintLapCard({super.key, required this.lapNumber, required this.completed, this.time, this.speed, this.distance});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SprintSessionsScreenState>()!;
    final isActive = !completed && (state._activeLap == lapNumber);

    Color accent;
    if (completed) accent = Colors.green;
    else if (isActive) accent = Colors.orange;
    else accent = Colors.grey;

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
              child: Text(lapNumber.toString(), style: TextStyle(color: accent, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: completed
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Finished in $time', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 7),
                  Row(children: [
                    Icon(Icons.speed, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 6),
                    Text(speed ?? '-', style: const TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 18),
                    Icon(Icons.straighten, color: Colors.blue, size: 18),
                    const SizedBox(width: 6),
                    Text(distance ?? '${state._distancePerLap} m', style: const TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.w600, fontSize: 14)),
                  ]),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isActive ? 'Lap in progress...' : 'Waiting for data...', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 16, color: isActive ? Colors.black87 : Colors.grey)),
                  const SizedBox(height: 7),
                  Text(isActive ? 'Complete the lap to see results' : 'Lap not started yet', style: TextStyle(color: Colors.grey, fontFamily: 'NunitoSans', fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}