import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/screens/chat.dart';
import 'package:corn_addiction/screens/settings.dart';
import 'package:corn_addiction/screens/stats/stats_screen.dart';
import 'package:corn_addiction/screens/recovery/recovery_toolkit_screen.dart';
import 'package:corn_addiction/screens/recovery/breathing_exercise_screen.dart';
import 'package:corn_addiction/screens/recovery/meditation_screen.dart';
import 'package:corn_addiction/screens/recovery/habit_tracker_screen.dart';

import '../dashboard.dart';
import '../tools/tools_screen.dart';

// Provider for the selected tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late List<Widget> _screens;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up screens
    _screens = [
      const DashboardScreen(),
      const RecoveryToolkitScreen(),
      const StatsScreen(),
      const ChatScreen(),
      const Settings(),
    ];

    // Set up FAB animations
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    ));

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[selectedTab],
      ),
      floatingActionButton: _buildFAB(selectedTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(selectedTab),
    );
  }

  Widget? _buildFAB(int selectedTab) {
    // Only show FAB on certain tabs
    if (selectedTab == 0 || selectedTab == 1 || selectedTab == 2) {
      return ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent,
                AppColors.accent.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showLogUrgeBottomSheet(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildBottomNavBar(int selectedTab) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        notchMargin: 12,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotch(
          notchMargin: 12,
          notchRadius: 32,
        ),
        child: Container(
          height: 130,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child:
                      _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard')),
              Expanded(
                  child: _buildNavItem(1, Icons.build_rounded, 'Recovery')),
              const SizedBox(width: 56), // Space for FAB
              Expanded(
                  child: _buildNavItem(2, Icons.insert_chart_rounded, 'Stats')),
              Expanded(
                  child: _buildNavItem(4, Icons.settings_rounded, 'Settings')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = ref.watch(selectedTabProvider) == index;

    return InkWell(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;

        // Animate FAB when needed
        if (index == 0 || index == 1 || index == 2) {
          if (!_fabAnimationController.isCompleted) {
            _fabAnimationController.forward();
          }
        } else {
          _fabAnimationController.reverse();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogUrgeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogUrgeBottomSheet(),
    );
  }
}

// Custom notched shape for bottom app bar
class CircularNotch implements NotchedShape {
  final double notchMargin;
  final double notchRadius;

  const CircularNotch({
    required this.notchMargin,
    required this.notchRadius,
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final notchRadius = this.notchRadius;
    const s1 = 18.0;
    const s2 = 2.0;

    final r = notchRadius;
    final x = guest.center.dx;
    final y = host.top;

    final double notchX1 = x - r - notchMargin / 2;
    final double notchX2 = x + r + notchMargin / 2;

    final path = Path()
      ..moveTo(host.left, host.top)
      ..lineTo(notchX1, host.top)
      ..cubicTo(
        notchX1 + s1,
        host.top,
        notchX1 + s2,
        y + r,
        x,
        y + r,
      )
      ..cubicTo(
        notchX2 - s2,
        y + r,
        notchX2 - s1,
        host.top,
        notchX2,
        host.top,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}

class LogUrgeBottomSheet extends StatefulWidget {
  const LogUrgeBottomSheet({Key? key}) : super(key: key);

  @override
  State<LogUrgeBottomSheet> createState() => _LogUrgeBottomSheetState();
}

class _LogUrgeBottomSheetState extends State<LogUrgeBottomSheet> {
  double urgeIntensity = 5.0;
  bool didRelapse = false;
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Color _getUrgeIntensityColor(double intensity) {
    if (intensity <= 3) {
      return const Color(0xFF4CAF50); // Light green
    } else if (intensity <= 7) {
      return const Color(0xFFFFA726); // Orange
    } else {
      return const Color(0xFFE53935); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log an Urge',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'How strong is your urge?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: _getUrgeIntensityColor(urgeIntensity)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getUrgeIntensityColor(urgeIntensity)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mild',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Moderate',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Severe',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('1',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 8,
                            activeTrackColor:
                                _getUrgeIntensityColor(urgeIntensity),
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: _getUrgeIntensityColor(urgeIntensity),
                            overlayColor: _getUrgeIntensityColor(urgeIntensity)
                                .withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 24),
                          ),
                          child: Slider(
                            value: urgeIntensity,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (value) {
                              setState(() {
                                urgeIntensity = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Text('10',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getUrgeIntensityColor(urgeIntensity),
                    ),
                    child: Center(
                      child: Text(
                        urgeIntensity.round().toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  'I relapsed',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: didRelapse ? Colors.red : Colors.grey[800],
                  ),
                ),
                value: didRelapse,
                onChanged: (value) {
                  setState(() {
                    didRelapse = value ?? false;
                  });
                },
                activeColor: Colors.red,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What triggered this urge?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Add notes about what triggered you...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Save urge log to Firestore
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Log',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
