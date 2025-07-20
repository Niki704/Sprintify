import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _userId;

  // Controllers and state variables
  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedGender;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int? _age;
  double? _bmi;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    _userId = user.uid;
    final docSnap = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      _nameController.text = data['name'] ?? '';

      if (data['dateOfBirth'] != null) {
        _dateOfBirth = (data['dateOfBirth'] as Timestamp).toDate();
        _calculateAge();
      }

      _addressController.text = data['address'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _selectedGender = data['gender'];
      _heightController.text = data['height']?.toString() ?? '';
      _weightController.text = data['weight']?.toString() ?? '';
      _calculateBmi();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _calculateAge() {
    if (_dateOfBirth == null) {
      setState(() => _age = null);
      return;
    }
    final today = DateTime.now();
    int age = today.year - _dateOfBirth!.year;
    if (today.month < _dateOfBirth!.month ||
        (today.month == _dateOfBirth!.month && today.day < _dateOfBirth!.day)) {
      age--;
    }
    setState(() => _age = age);
  }

  void _calculateBmi() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    if (height > 0 && weight > 0) {
      setState(() {
        _bmi = weight / ((height / 100) * (height / 100));
      });
    } else {
      setState(() => _bmi = null);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _calculateAge();
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      if (_userId == null) return;

      try {
        final userData = {
          'name': _nameController.text.trim(),
          'dateOfBirth': _dateOfBirth,
          'address': _addressController.text.trim(),
          'contact': _contactController.text.trim(),
          'gender': _selectedGender,
          'height': double.tryParse(_heightController.text.trim()),
          'weight': double.tryParse(_weightController.text.trim()),
          'lastUpdated': DateTime.now().toIso8601String(),
          // --- THIS LINE WILL DELETE THE OLD FIELD ---
          'age': FieldValue.delete(),
        };

        await FirebaseFirestore.instance.collection('users').doc(_userId).set(
            userData,
            SetOptions(merge: true)
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $error')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 56,
                backgroundImage: AssetImage('assets/profile-img.png'),
              ),
              const SizedBox(height: 24),
              // Personal Data Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Personal Data", style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.deepPurple)),
                      const SizedBox(height: 12),
                      _buildTextFormField(controller: _nameController, label: "Name"),
                      _buildDatePicker(),
                      _ProfileInfoRow(label: "Age", value: _age?.toString() ?? "N/A"),
                      _buildTextFormField(controller: _addressController, label: "Address"),
                      _buildTextFormField(controller: _contactController, label: "Contact", keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
              ),
              // Bio Data Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bio Data", style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.deepPurple)),
                      const SizedBox(height: 12),
                      _buildGenderDropdown(),
                      _buildTextFormField(controller: _heightController, label: "Height (cm)", keyboardType: TextInputType.number),
                      _buildTextFormField(controller: _weightController, label: "Weight (kg)", keyboardType: TextInputType.number),
                      _ProfileInfoRow(label: "BMI", value: _bmi?.toStringAsFixed(1) ?? "N/A"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Save Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            _dateOfBirth != null ? DateFormat.yMMMd().format(_dateOfBirth!) : 'Select a date',
            style: TextStyle(color: _dateOfBirth != null ? Colors.black : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: ['Male', 'Female', 'Prefer not to say']
            .map((label) => DropdownMenuItem(child: Text(label), value: label))
            .toList(),
        onChanged: (value) => setState(() => _selectedGender = value),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) => null,
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
          SizedBox(width: 90, child: Text("$label:", style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 15))),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Catamaran', fontSize: 15))),
        ],
      ),
    );
  }
}