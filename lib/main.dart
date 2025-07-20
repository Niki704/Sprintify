import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprintify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Use a StreamBuilder to check the auth state
      home: StreamBuilder<User?>(
        // Listen to the authStateChanges stream from Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // 1. If the connection is still loading, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 2. If the snapshot has data, it means the user is logged in
          if (snapshot.hasData) {
            // User is signed in, show the DashboardScreen
            return const DashboardScreen();
          }

          // 3. If the snapshot has no data, the user is not logged in
          // Show the HomeScreen with Login/Sign Up buttons
          return const HomeScreen();
        },
      ),
    );
  }
}