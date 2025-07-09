import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'setup_race_screen.dart';
import 'start_race_screen.dart';
import 'sprint_sessions_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'home_screen.dart';

// --- MODERNIZED DASHBOARD SCREEN v4 ---

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const List<DashboardTile> dashboardTiles = [
    DashboardTile(
      title: "My Profile",
      icon: Icons.person,
      color: Color(0xFF2766E2),
      gradient: LinearGradient(
        colors: [Color(0xFF2766E2), Color(0xFF528FF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Setup Race",
      icon: Icons.settings_input_component_rounded,
      color: Color(0xFF00C6FB),
      gradient: LinearGradient(
        colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Start Race",
      icon: Icons.flag_rounded,
      color: Color(0xFFFF5F6D),
      gradient: LinearGradient(
        colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Sprint Sessions",
      icon: Icons.directions_run,
      color: Color(0xFFFF9300),
      gradient: LinearGradient(
        colors: [Color(0xFFFF9300), Color(0xFFFFB347)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Statistics",
      icon: Icons.bar_chart,
      color: Color(0xFFEA2B2B),
      gradient: LinearGradient(
        colors: [Color(0xFFEA2B2B), Color(0xFFFF4C4C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Achievements",
      icon: Icons.emoji_events,
      color: Color(0xFF8E54E9),
      gradient: LinearGradient(
        colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Settings",
      icon: Icons.settings,
      color: Color(0xFF1FD1F9),
      gradient: LinearGradient(
        colors: [Color(0xFF1FD1F9), Color(0xFF39C2F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardTile(
      title: "Help",
      icon: Icons.help_outline,
      color: Color(0xFF232526),
      gradient: LinearGradient(
        colors: [Color(0xFF232526), Color(0xFF414345)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// =================== ADDED: DashboardScreen state with blur overlay flag ===================
class _DashboardScreenState extends State<DashboardScreen> {
  bool _menuOpen = false;

  void _setMenuOpen(bool open) {
    setState(() => _menuOpen = open);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _AnimatedGradientBackground(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                color: Colors.black.withOpacity(0.20),
              ),
            ),
          ),
          // =================== ADDED: Animated blurred overlay for menu ===================
          AnimatedOpacity(
            opacity: _menuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !_menuOpen,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: Colors.black.withOpacity(0.09),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
                  child: SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Dashboard',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: Colors.white.withOpacity(0.97),
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // =================== CHANGED: Pass blur callback to menu button ===================
                        Positioned(
                          right: 16,
                          child: _ProfileMenuButton(onMenuOpen: _setMenuOpen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 10, bottom: 18),
                    itemCount: DashboardScreen.dashboardTiles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _AnimatedFancyTile(
                        tile: DashboardScreen.dashboardTiles[index],
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SetupRaceScreen()),
                            );
                          } else if (index == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StartRaceScreen()),
                            );
                          } else if (index == 3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SprintSessionsScreen()),
                            );
                          } else if (index == 4) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                            );
                          } else if (index == 5) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                            );
                          } else if (index == 6) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          } else if (index == 7) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HelpScreen()),
                            );
                          }
                        },
                        animationDelay: index * 100,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
// =================== END changes for blur overlay ===================
}

// --- MODERN PROFILE MENU BUTTON ---
class _ProfileMenuButton extends StatefulWidget {
  final void Function(bool)? onMenuOpen;
  const _ProfileMenuButton({this.onMenuOpen, super.key});

  @override
  State<_ProfileMenuButton> createState() => _ProfileMenuButtonState();
}

class _ProfileMenuButtonState extends State<_ProfileMenuButton> {
  final GlobalKey _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _iconKey,
      onTap: () async {
        // Get the position of the icon for the menu anchor
        final RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;

        widget.onMenuOpen?.call(true);

        final selected = await showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + size.height + 6, // slightly below the icon
            offset.dx + size.width,
            offset.dy,
          ),
          color: const Color(0xFFE7F1F9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // adjust the value for more/less curve
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              child: _ProfileMenuHeader(),
            ),
            const PopupMenuDivider(),
            _modernMenuItem(
              context,
              icon: Icons.person,
              text: "Profile",
              value: 0,
              color: const Color(0xFF2766E2),
            ),
            _modernMenuItem(
              context,
              icon: Icons.settings_input_component_rounded,
              text: "Setup Race",
              value: 1,
              color: const Color(0xFF00C6FB),
            ),
            _modernMenuItem(
              context,
              icon: Icons.directions_run,
              text: "Previous Sessions",
              value: 2,
              color: const Color(0xFFFF9300),
            ),
            _modernMenuItem(
              context,
              icon: Icons.settings,
              text: "Settings",
              value: 3,
              color: const Color(0xFF1FD1F9),
            ),
            _modernMenuItem(
              context,
              icon: Icons.help_outline,
              text: "Support",
              value: 4,
              color: const Color(0xFF232526),
            ),
            const PopupMenuDivider(),
            _modernMenuItem(
              context,
              icon: Icons.logout,
              text: "Logout",
              value: 5,
              color: const Color(0xFFFF5F6D),
              isDestructive: true,
            ),
          ],
        );
        widget.onMenuOpen?.call(false);
        if (!context.mounted) return;

        switch (selected) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupRaceScreen()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SprintSessionsScreen()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            break;
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
            break;
          case 5:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
            break;
          default:
        }
      },
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white.withOpacity(0.18),
        child: const Icon(
          Icons.account_circle,
          color: Colors.white70,
          size: 36,
        ),
      ),
    );
  }
}

// --- GLASSY HEADER FOR CONTEXT MENU ---
class _ProfileMenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                radius: 18,
                child: const Icon(Icons.person, size: 22, color: Color(0xFF2766E2)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Niki704", // TODO: Replace with actual user name if available
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "View your profile",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 11.5,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MODERN MENU ITEM HELPER ---
PopupMenuItem<int> _modernMenuItem(
    BuildContext context, {
      required IconData icon,
      required String text,
      required int value,
      required Color color,
      bool isDestructive = false,
    }) {
  return PopupMenuItem<int>(
    value: value,
    child: Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color.withOpacity(0.13),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: isDestructive ? const Color(0xFFFF5F6D) : Colors.black.withOpacity(0.82),
          ),
        ),
      ],
    ),
  );
}

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({super.key});

  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const List<List<Color>> gradientColors = [
    [Color(0xFF232536), Color(0xFF4abdfb), Color(0xFFad5adc)],
    [Color(0xFF8E54E9), Color(0xFF4776E6), Color(0xFFf1b5e7)],
    [Color(0xFF232526), Color(0xFF1FD1F9), Color(0xFF39C2F7)],
  ];

  int colorSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final colors1 = gradientColors[colorSetIndex % gradientColors.length];
        final colors2 = gradientColors[(colorSetIndex + 1) % gradientColors.length];
        final colors = List.generate(
          3,
              (i) => Color.lerp(colors1[i], colors2[i], t)!,
        );
        if (_animation.status == AnimationStatus.completed) {
          colorSetIndex = (colorSetIndex + 1) % gradientColors.length;
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        );
      },
    );
  }
}

class DashboardTile {
  final String title;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const DashboardTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class _AnimatedFancyTile extends StatefulWidget {
  final DashboardTile tile;
  final VoidCallback? onTap;
  final int animationDelay;

  const _AnimatedFancyTile({
    required this.tile,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<_AnimatedFancyTile> createState() => _AnimatedFancyTileState();
}

class _AnimatedFancyTileState extends State<_AnimatedFancyTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            height: 116,
            decoration: BoxDecoration(
              gradient: widget.tile.gradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                // Highlight: Use withOpacity instead of withValues/withAlpha
                BoxShadow(
                  color: widget.tile.color.withOpacity(_pressed ? 0.15 : 0.22),
                  blurRadius: _pressed ? 8 : 18,
                  offset: const Offset(0, 6),
                ),
                if (_pressed)
                  BoxShadow(
                    color: widget.tile.color.withOpacity(0.25),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1.2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
                Positioned(
                  right: -24,
                  top: -10,
                  bottom: -10,
                  child: Icon(
                    widget.tile.icon,
                    size: 148,
                    color: Colors.white.withOpacity(0.09),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.tile.color.withOpacity(0.40),
                              blurRadius: 16,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.90),
                          radius: 32,
                          child: Icon(
                            widget.tile.icon,
                            size: 36,
                            color: widget.tile.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Text(
                          widget.tile.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.97),
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.19),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}