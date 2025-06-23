import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'sprint_sessions_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // dashboard features
  final List<_DashboardTile> dashboardTiles = const [
    _DashboardTile(
      title: "My Profile",
      icon: Icons.person,
      color: Color(0xFF2766E2), // blue
      gradient: LinearGradient(
        colors: [Color(0xFF2766E2), Color(0xFF528FF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _DashboardTile(
      title: "Sprint Sessions",
      icon: Icons.directions_run,
      color: Color(0xFFFF9300), // orange
      gradient: LinearGradient(
        colors: [Color(0xFFFF9300), Color(0xFFFFB347)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _DashboardTile(
      title: "Statistics",
      icon: Icons.bar_chart,
      color: Color(0xFFEA2B2B), // red
      gradient: LinearGradient(
        colors: [Color(0xFFEA2B2B), Color(0xFFFF4C4C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _DashboardTile(
      title: "Achievements",
      icon: Icons.emoji_events,
      color: Color(0xFF8E54E9), // purple
      gradient: LinearGradient(
        colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _DashboardTile(
      title: "Settings",
      icon: Icons.settings,
      color: Color(0xFF1FD1F9), // teal/blue
      gradient: LinearGradient(
        colors: [Color(0xFF1FD1F9), Color(0xFF39C2F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _DashboardTile(
      title: "Help",
      icon: Icons.help_outline,
      color: Color(0xFF232526), // dark
      gradient: LinearGradient(
        colors: [Color(0xFF232526), Color(0xFF414345)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232536),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: dashboardTiles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _FancyTile(
              tile: dashboardTiles[index],
              onTap: () {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SprintSessionsScreen()),
                  );
                }
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                }
                if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                }
                if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
                if (index == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _DashboardTile {
  final String title;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _DashboardTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class _FancyTile extends StatelessWidget {
  final _DashboardTile tile;
  final VoidCallback? onTap;

  const _FancyTile({required this.tile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: tile.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: tile.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              right: -20,
              top: 0,
              bottom: 0,
              child: Icon(
                tile.icon,
                size: 140,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 32,
                    child: Icon(
                      tile.icon,
                      size: 36,
                      color: tile.color,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Text(
                      tile.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
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