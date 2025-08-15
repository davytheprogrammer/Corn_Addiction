import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'dart:async';
import 'dart:math' as math;

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _rippleAnimation;

  Timer? _timer;
  Timer? _phaseTimer;
  int _currentPhase = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  int _countdown = 4;
  bool _isActive = false;
  int _completedCycles = 0;

  final List<String> _phaseNames = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<int> _phaseDurations = [4, 7, 8, 2]; // 4-7-8 breathing technique
  final List<Color> _phaseColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rippleController.dispose();
    _timer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _currentPhase = 0;
      _countdown = _phaseDurations[0];
      _completedCycles = 0;
    });

    _startPhase();
  }

  void _stopBreathing() {
    setState(() {
      _isActive = false;
    });

    _timer?.cancel();
    _phaseTimer?.cancel();
    _breathingController.reset();
    _rippleController.reset();
  }

  void _startPhase() {
    _breathingController.duration =
        Duration(seconds: _phaseDurations[_currentPhase]);

    if (_currentPhase == 0) {
      // Inhale
      _breathingController.forward();
    } else if (_currentPhase == 2) {
      // Exhale
      _breathingController.reverse();
    }

    _rippleController.repeat();

    _countdown = _phaseDurations[_currentPhase];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    setState(() {
      _currentPhase = (_currentPhase + 1) % 4;

      if (_currentPhase == 0) {
        _completedCycles++;
      }
    });

    if (_isActive) {
      _startPhase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _phaseColors[_currentPhase].withValues(alpha: 0.1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Breathing Exercise',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBreathingCircle(),
                    const SizedBox(height: 40),
                    _buildPhaseIndicator(),
                    const SizedBox(height: 20),
                    _buildCountdown(),
                    const SizedBox(height: 40),
                    _buildStats(),
                  ],
                ),
              ),
            ),
            _buildControls(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effects
                for (int i = 0; i < 3; i++)
                  Transform.scale(
                    scale: _rippleAnimation.value * (1 + i * 0.3),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _phaseColors[_currentPhase].withValues(
                            alpha: (1 - _rippleAnimation.value) * 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                // Main breathing circle
                Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _phaseColors[_currentPhase].withValues(alpha: 0.8),
                          _phaseColors[_currentPhase].withValues(alpha: 0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _phaseColors[_currentPhase]
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getPhaseIcon(),
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _phaseColors[_currentPhase].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _phaseColors[_currentPhase].withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        _phaseNames[_currentPhase],
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _phaseColors[_currentPhase],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    return Text(
      _countdown.toString(),
      style: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: _phaseColors[_currentPhase],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Cycles', _completedCycles.toString()),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          _buildStatItem('Phase', '${_currentPhase + 1}/4'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isActive ? _stopBreathing : _startBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActive ? Colors.red : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _isActive ? 'Stop' : 'Start',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon() {
    switch (_currentPhase) {
      case 0:
        return Icons.keyboard_arrow_up_rounded; // Inhale
      case 1:
        return Icons.pause_rounded; // Hold
      case 2:
        return Icons.keyboard_arrow_down_rounded; // Exhale
      case 3:
        return Icons.pause_rounded; // Hold
      default:
        return Icons.air_rounded;
    }
  }
}
