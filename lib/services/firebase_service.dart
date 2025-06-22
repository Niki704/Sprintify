// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/sprint_session.dart';
//
// class FirebaseService {
//   final _sessionsRef = FirebaseFirestore.instance.collection('sessions');
//
//   Stream<List<SprintSession>> getSessions() {
//     return _sessionsRef.snapshots().map((snapshot) =>
//         snapshot.docs.map((doc) => SprintSession.fromMap(doc.data())).toList()
//     );
//   }
//
// // Add methods to write sessions, update settings, etc.
// }