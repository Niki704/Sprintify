import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example lap data
    final laps = [
      {'time': 20, 'speed': 32.4},
      {'time': 21, 'speed': 30.1},
      {'time': 19, 'speed': 29.8},
      {'time': 45, 'speed': 23.0},
    ];

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
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 40,
                        minY: 0,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) => Text(
                                value % 10 == 0 ? value.toInt().toString() : '',
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
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Lap ${value.toInt() + 1}",
                                  style: const TextStyle(
                                    fontFamily: 'NunitoSans',
                                    color: Colors.deepPurple,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              interval: 1,
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          laps.length,
                              (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: laps[i]['speed'] as double,
                                color: Colors.deepPurpleAccent,
                                width: 28,
                                borderRadius: BorderRadius.circular(8),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 40,
                                  color: Colors.deepPurple.withOpacity(0.08),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [0],
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
                                    text: 'Speed: ${rod.toY} m/s',
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
            // Laps List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: laps.length,
                itemBuilder: (context, i) {
                  return _LapStatCard(
                    lapNumber: i + 1,
                    time: laps[i]['time'] as int,
                    speed: laps[i]['speed'] as double,
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