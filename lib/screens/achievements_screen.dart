import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<QueryDocumentSnapshot> _sessions = [];
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  /// Fetches and sorts all race sessions from Firestore for the current user.
  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _message = 'Please log in to view achievements.';
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
          _message = 'No saved sessions found!';
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error fetching achievements.';
      });
    }
  }

  /// Shows a scrollable dialog with detailed session and lap information.
  Future<void> _showDetailsDialog(QueryDocumentSnapshot session) async {
    final sessionData = session.data() as Map<String, dynamic>;
    final lapsData = sessionData['laps'];
    final distancePerLap = (sessionData['distancePerLap'] ?? 0).toDouble();
    final lapCount = (sessionData['lapCount'] ?? 0);

    final List<Widget> lapWidgets = [];
    for (int i = 1; i <= lapCount; i++) {
      Map<dynamic, dynamic>? lap;
      if (lapsData is List) {
        if (i < lapsData.length) lap = lapsData[i] as Map<dynamic, dynamic>?;
      } else if (lapsData is Map) {
        lap = lapsData[i.toString()] as Map<dynamic, dynamic>?;
      }

      if (lap != null && lap['startTime'] != null && lap['endTime'] != null) {
        final timeTakenMs = lap['endTime'] - lap['startTime'];
        final timeInSec = (timeTakenMs / 1000).toStringAsFixed(2);
        final speed = (distancePerLap > 0 && timeTakenMs > 0)
            ? (distancePerLap / (timeTakenMs / 1000)).toStringAsFixed(2)
            : '0.00';

        lapWidgets.add(
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                child: Text(i.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ),
              title: Text('Time: $timeInSec sec'),
              subtitle: Text('Avg Speed: $speed m/s'),
            )
        );
        lapWidgets.add(const Divider(height: 1));
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Session ${session.id.split('_').last} Details', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Laps: $lapCount', style: const TextStyle(fontSize: 16)),
                  Text('Distance Per Lap: $distancePerLap m', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('Lap Breakdown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...lapWidgets,
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog and deletes the session if confirmed.
  Future<void> _deleteSession(String sessionId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        // --- FIX: Applied consistent dialog theme ---
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to permanently delete this session? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF2e2e2e))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sessions')
            .doc(sessionId)
            .delete();

        setState(() {
          _sessions.removeWhere((session) => session.id == sessionId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session deleted successfully.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting session: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _message.isNotEmpty
            ? Center(child: Text(_message, style: const TextStyle(fontSize: 16, color: Colors.grey)))
            : ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: _sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final session = _sessions[i];
            final sessionData = session.data() as Map<String, dynamic>;
            final date = (sessionData['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return _AchievementTile(
              index: i,
              id: session.id,
              distance: (sessionData['distancePerLap'] ?? 0.0).toDouble(),
              laps: sessionData['lapCount'] ?? 0,
              date: date,
              onDetails: () => _showDetailsDialog(session),
              onDelete: () => _deleteSession(session.id),
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
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const _AchievementTile({
    required this.index,
    required this.id,
    required this.distance,
    required this.laps,
    required this.date,
    required this.onDetails,
    required this.onDelete,
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
    final formattedTime = DateFormat('HH:mm:ss').format(date);
    final accentColor = _getAccentColor(index);

    return Card(
      elevation: 2,
      shadowColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Session ${id.split('_').last}",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Distance: ${distance.toStringAsFixed(1)}m | Laps: $laps",
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 14,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Date: $formattedDate",
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 13.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time: $formattedTime",
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 13.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onDetails,
                    child: const Text(
                      "Details",
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onDelete,
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