import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showLoading = true;
  bool _logoInCorner = false;
  late final AnimationController _btnController;
  late final Animation<Offset> _btnOffset;

  // Title animation controllers/animations
  late final AnimationController _titleController;
  late final Animation<double> _titleFontSize;
  late final Animation<double> _titleYOffset;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _btnOffset = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeOut));

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _titleFontSize = Tween<double>(
      begin: 36,
      end: 46,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeInOut));

    _titleYOffset = Tween<double>(
      begin: 0,
      end: -32,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showLoading = false;
      });
      // Wait for loading animation to finish, then animate logo
      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() {
          _logoInCorner = true;
        });
        _btnController.forward();
        _titleController.forward();
      });
    });
  }

  @override
  void dispose() {
    _btnController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double initialLogoSize = 120;
    const double finalLogoSize = 48;
    return Scaffold(
      // backgroundColor: const Color(0xFFE3F2FD),
      body: Container(
        // --- ADDED GRADIENT BACKGROUND HERE ---
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4abdfb), // Light Blue
              Color(0xFFad5adc), // Purple
              Color(0xFFf1b5e7), // Pink Lavender
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for logo (to keep spacing)
                    const SizedBox(height: initialLogoSize + 24),
                    // Name
                    // Animated Title
                    AnimatedBuilder(
                      animation: _titleController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _titleYOffset.value),
                          child: Text(
                            "Sprintify",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: _titleFontSize.value,
                                color: const Color(0xFF3c1361),
                                letterSpacing: 1.5,
                              )
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "Track, analyze, and improve your sprint sessions effortlessly. "
                            "Sprintify empowers athletes and coaches with real-time stats, session history, "
                            "and performance insights — all in one place.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Catamaran',
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Loading spinner (show for 3 seconds)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _showLoading
                          ? const Column(
                        key: ValueKey('loader'),
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF2e2e2e),
                          ),
                          SizedBox(height: 40),
                        ],
                      )
                          : const SizedBox(height: 40), // Placeholder
                    ),
                    // Animated Login and Sign Up Buttons
                    AnimatedOpacity(
                      opacity: _logoInCorner ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      child: SlideTransition(
                        position: _btnOffset,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2e2e2e),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _showLoading
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const DashboardScreen()),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2e2e2e),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _showLoading
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const DashboardScreen()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Animated Logo
            AnimatedAlign(
              alignment: _logoInCorner
                  ? Alignment.topRight
                  : const Alignment(0, -0.62),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                margin: EdgeInsets.only(
                  top: _logoInCorner ? 48 : 0,
                  right: _logoInCorner ? 32 : 0,
                  left: _logoInCorner ? 0 : 0,
                ),
                height: _logoInCorner ? finalLogoSize : initialLogoSize,
                width: _logoInCorner ? finalLogoSize : initialLogoSize,
                child: ClipOval(
                  child: Image.asset(
                    'assets/sprintify-logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}