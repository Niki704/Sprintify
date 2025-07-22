import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<QueryDocumentSnapshot> _sessions = [];
  QueryDocumentSnapshot? _selectedSession;
  List<Map<String, dynamic>> _laps = [];
  double _maxSpeed = 0;
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  /// Fetches all saved race sessions from Firestore for the current user.
  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _message = 'Please log in to see statistics.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _message = 'No saved sessions found.';
        });
        return;
      }

      List<QueryDocumentSnapshot> sortedSessions = snapshot.docs;
      sortedSessions.sort((a, b) {
        int aNum = int.tryParse(a.id.split('_').last) ?? 0;
        int bNum = int.tryParse(b.id.split('_').last) ?? 0;
        return aNum.compareTo(bNum);
      });

      setState(() {
        _sessions = sortedSessions;
        _selectedSession = _sessions.last;
        _isLoading = false;
      });

      _processSelectedSession();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error fetching sessions.';
      });
    }
  }

  /// Processes the data from the currently selected session to update the UI.
  void _processSelectedSession() {
    if (_selectedSession == null) return;

    final sessionData = _selectedSession!.data() as Map<String, dynamic>;
    final lapsData = sessionData['laps'];
    final distancePerLap = (sessionData['distancePerLap'] ?? 0).toDouble();
    final lapCount = (sessionData['lapCount'] ?? 0);

    final generatedLaps = <Map<String, dynamic>>[];
    double currentMaxSpeed = 0;

    for (int i = 1; i <= lapCount; i++) {
      Map<dynamic, dynamic>? lap;
      if (lapsData is List) {
        if (i < lapsData.length) {
          lap = lapsData[i] as Map<dynamic, dynamic>?;
        }
      } else if (lapsData is Map) {
        lap = lapsData[i.toString()] as Map<dynamic, dynamic>?;
      }

      if (lap != null && lap['startTime'] != null && lap['endTime'] != null) {
        final timeTakenMs = lap['endTime'] - lap['startTime'];
        final timeInSec = timeTakenMs / 1000;

        final speed = (distancePerLap > 0 && timeInSec > 0)
            ? (distancePerLap / timeInSec)
            : 0.0;

        if (speed > currentMaxSpeed) {
          currentMaxSpeed = speed;
        }

        generatedLaps.add({
          'time': timeInSec.round(),
          'speed': speed,
        });
      }
    }

    setState(() {
      _laps = generatedLaps;
      // --- Y-AXIS SCALING IMPROVEMENT ---
      if (currentMaxSpeed == 0) {
        _maxSpeed = 30; // A sensible default if there's no speed data.
      } else {
        // Add 20% padding and round up to the nearest 5.
        final paddedMax = currentMaxSpeed * 1.2;
        _maxSpeed = (paddedMax / 5).ceil() * 5.0;
      }
    });
  }

  // --- DYNAMIC Y-AXIS LABEL IMPROVEMENT ---
  /// Determines the interval for Y-axis labels based on the max speed.
  double _getLabelInterval(double max) {
    if (max <= 10) return 2;
    if (max <= 50) return 5;
    if (max <= 100) return 10;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sprint Statistics',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        color: const Color(0xFFFAFAFD),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _message.isNotEmpty
            ? Center(child: Text(_message, style: const TextStyle(fontSize: 16, color: Colors.grey)))
            : Column(
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Lap Speed Overview',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _maxSpeed,
                        minY: 0,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: _getLabelInterval(_maxSpeed),
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value > _maxSpeed) return const SizedBox();
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontFamily: 'NunitoSans',
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final String text = _laps.length > 7
                                    ? (value.toInt() + 1).toString()
                                    : "Lap ${value.toInt() + 1}";
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontFamily: 'NunitoSans',
                                      color: Colors.deepPurple,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                              interval: 1,
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          _laps.length,
                              (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: _laps[i]['speed'] as double,
                                color: Colors.deepPurpleAccent,
                                width: 28,
                                borderRadius: BorderRadius.circular(8),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: _maxSpeed,
                                  color: Colors.deepPurple.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.deepPurple.withOpacity(0.85),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Lap ${group.x + 1}\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Speed: ${rod.toY.toStringAsFixed(1)} m/s',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.deepPurple.withOpacity(0.07),
                            dashArray: [5, 2],
                            strokeWidth: 1,
                          ),
                          horizontalInterval: _getLabelInterval(_maxSpeed),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 16.0, right: 20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
                    ),
                    child: DropdownButton<QueryDocumentSnapshot>(
                      value: _selectedSession,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                      onChanged: (QueryDocumentSnapshot? newValue) {
                        setState(() {
                          _selectedSession = newValue;
                        });
                        _processSelectedSession();
                      },
                      items: _sessions.map<DropdownMenuItem<QueryDocumentSnapshot>>((session) {
                        return DropdownMenuItem<QueryDocumentSnapshot>(
                          value: session,
                          child: Text(
                            'Session ${session.id.split('_').last}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _laps.length,
                itemBuilder: (context, i) {
                  return _LapStatCard(
                    lapNumber: i + 1,
                    time: _laps[i]['time'] as int,
                    speed: _laps[i]['speed'] as double,
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

class _LapStatCard extends StatelessWidget {
  final int lapNumber;
  final int time;
  final double speed;

  const _LapStatCard({
    required this.lapNumber,
    required this.time,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: lapNumber.isEven
          ? Colors.deepPurple.withOpacity(0.08)
          : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            lapNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          "Time: $time sec",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: Text(
            "Speed: ${speed.toStringAsFixed(1)} m/s",
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontSize: 13.5,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.show_chart,
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}