import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // Imported for generating random data

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // --- DYNAMIC LAP CONTROL ---
  // You can change this value to control the number of laps.
  // Set to 10 to demonstrate the conditional label change.
  final int totalLaps = 7;

  // This list will be populated with generated statistics.
  late List<Map<String, dynamic>> _laps;
  double _maxSpeed = 0; // To dynamically set the chart's max Y value.

  @override
  void initState() {
    super.initState();
    _generateLapStatistics();
  }

  /// Generates sample lap statistics based on the `totalLaps` variable.
  void _generateLapStatistics() {
    final random = Random();
    final generatedLaps = <Map<String, dynamic>>[];
    double currentMaxSpeed = 0;

    for (int i = 0; i < totalLaps; i++) {
      final time = random.nextInt(15) + 18; // Random time between 18 and 32
      final speed = random.nextDouble() * 15 + 20; // Random speed between 20.0 and 35.0

      if (speed > currentMaxSpeed) {
        currentMaxSpeed = speed;
      }

      generatedLaps.add({
        'time': time,
        'speed': speed,
      });
    }

    setState(() {
      _laps = generatedLaps;
      // Set max speed for the chart, rounding up to the nearest 10 for a clean look.
      _maxSpeed = (currentMaxSpeed / 10).ceil() * 10.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until the data is generated.
    if (_laps == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sprint Statistics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Card with custom-styled chart
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
                        // --- DYNAMIC Y-AXIS ---
                        maxY: _maxSpeed,
                        minY: 0,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt() % 10 == 0 ? value.toInt().toString() : '',
                                style: const TextStyle(
                                  fontFamily: 'NunitoSans',
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // --- CONDITIONAL LABEL LOGIC ---
                                // If lap count is high, only show the number to prevent overlap.
                                final String text = totalLaps > 7
                                    ? (value.toInt() + 1).toString()
                                    : "Lap ${value.toInt() + 1}";

                                return Padding(
                                  padding: const EdgeInsets.only(left: 0, top: 4, right: 0, bottom: 0),
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
                        // --- DYNAMIC BAR GENERATION ---
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
                            // The 'showingTooltipIndicators' property has been removed.
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
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // --- DYNAMIC LAPS LIST ---
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
        trailing: Icon(
          Icons.show_chart,
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}