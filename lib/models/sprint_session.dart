class SprintSession {
  final String id;
  final DateTime date;
  final int lapCount;
  final double totalTime;
  final double topSpeed;

  SprintSession({
    required this.id,
    required this.date,
    required this.lapCount,
    required this.totalTime,
    required this.topSpeed,
  });

// Add fromMap/toMap for Firebase
}