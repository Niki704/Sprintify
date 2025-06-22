import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example user data (replace real user data in future)
    final String userName = "Niki 704";
    final int userAge = 23;
    final String userAddress = "No.415, Induruwa";
    final String userContact = "+94 76 989 8930";
    final String userGender = "Male";
    final double userHeight = 182.0; // cm
    final double userWeight = 87.6; //  kg
    final double userBMI = userWeight / ((userHeight / 100) * (userHeight / 100));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Circular photo
            CircleAvatar(
              radius: 56,
              backgroundImage: AssetImage('assets/profile-img.png'),
            ),
            const SizedBox(height: 24),
            // Personal Data
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Data",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoRow(label: "Name", value: userName),
                    _ProfileInfoRow(label: "Age", value: "$userAge"),
                    _ProfileInfoRow(label: "Address", value: userAddress),
                    _ProfileInfoRow(label: "Contact", value: userContact),
                  ],
                ),
              ),
            ),
            // Bio Data
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bio Data",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileInfoRow(label: "Gender", value: userGender),
                    _ProfileInfoRow(label: "Height", value: "${userHeight.toStringAsFixed(1)} cm"),
                    _ProfileInfoRow(label: "Weight", value: "${userWeight.toStringAsFixed(1)} kg"),
                    _ProfileInfoRow(label: "BMI", value: userBMI.toStringAsFixed(1)),
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

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Catamaran',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}