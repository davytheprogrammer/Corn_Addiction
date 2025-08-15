import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'dart:async';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final List<MeditationSession> _sessions = [
    MeditationSession(
      title: 'Mindful Breathing',
      duration: '5 min',
      description: 'Focus on your breath to find calm',
      icon: Icons.air_rounded,
      color: Colors.blue,
      script: [
        'Find a comfortable position and close your eyes.',
        'Take a deep breath in through your nose for 4 counts.',
        'Hold your breath for 4 counts.',
        'Exhale slowly through your mouth for 6 counts.',
        'Continue this pattern, focusing only on your breath.',
        'If your mind wanders, gently return to your breathing.',
        'You are in control. You are at peace.',
      ],
    ),
    MeditationSession(
      title: 'Body Scan',
      duration: '10 min',
      description: 'Release tension from head to toe',
      icon: Icons.accessibility_new_rounded,
      color: Colors.green,
      script: [
        'Lie down comfortably and close your eyes.',
        'Start by focusing on the top of your head.',
        'Notice any tension and breathe into that area.',
        'Slowly move your attention down to your forehead.',
        'Relax your eyes, cheeks, and jaw.',
        'Continue down your neck and shoulders.',
        'Let each part of your body relax completely.',
        'You are releasing all stress and tension.',
      ],
    ),
    MeditationSession(
      title: 'Loving Kindness',
      duration: '8 min',
      description: 'Cultivate self-compassion and forgiveness',
      icon: Icons.favorite_rounded,
      color: Colors.pink,
      script: [
        'Sit comfortably and place your hand on your heart.',
        'Take three deep breaths to center yourself.',
        'Repeat: "May I be happy and healthy."',
        'Repeat: "May I be at peace with myself."',
        'Repeat: "May I forgive myself for past mistakes."',
        'Repeat: "May I have the strength to heal."',
        'Feel the warmth of self-compassion in your heart.',
        'You deserve love, especially from yourself.',
      ],
    ),
    MeditationSession(
      title: 'Urge Surfing',
      duration: '7 min',
      description: 'Learn to ride out difficult urges',
      icon: Icons.waves_rounded,
      color: Colors.teal,
      script: [
        'Acknowledge the urge without judgment.',
        'Notice where you feel it in your body.',
        'Breathe deeply and observe the sensation.',
        'Imagine the urge as a wave in the ocean.',
        'Waves rise and fall naturally.',
        'You don\'t need to fight the wave or give in.',
        'Simply surf on top of it until it passes.',
        'This urge will pass. You have the strength.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Meditation',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSessionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple,
            Colors.purple.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Peace',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guided meditations for recovery',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meditation Sessions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...(_sessions
            .map((session) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSessionCard(session),
                ))
            .toList()),
      ],
    );
  }

  Widget _buildSessionCard(MeditationSession session) {
    return GestureDetector(
      onTap: () => _startMeditation(session),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: session.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                session.icon,
                color: session.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        session.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: session.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session.duration,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: session.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_filled_rounded,
              color: session.color,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  void _startMeditation(MeditationSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuidedMeditationScreen(session: session),
      ),
    );
  }
}

class MeditationSession {
  final String title;
  final String duration;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> script;

  MeditationSession({
    required this.title,
    required this.duration,
    required this.description,
    required this.icon,
    required this.color,
    required this.script,
  });
}

class GuidedMeditationScreen extends StatefulWidget {
  final MeditationSession session;

  const GuidedMeditationScreen({super.key, required this.session});

  @override
  State<GuidedMeditationScreen> createState() => _GuidedMeditationScreenState();
}

class _GuidedMeditationScreenState extends State<GuidedMeditationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  int _currentStep = 0;
  bool _isPlaying = false;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startMeditation() {
    setState(() {
      _isPlaying = true;
      _currentStep = 0;
      _secondsElapsed = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_currentStep < widget.session.script.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _completeMeditation();
      }
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          _secondsElapsed++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _pauseMeditation() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
  }

  void _completeMeditation() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Meditation Complete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Well done! You\'ve completed the ${widget.session.title} meditation.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.session.color.withValues(alpha: 0.1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.session.title,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulsingCircle(),
                      const SizedBox(height: 40),
                      _buildCurrentInstruction(),
                      const SizedBox(height: 40),
                      _buildProgress(),
                    ],
                  ),
                ),
              ),
              _buildControls(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingCircle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.session.color.withValues(alpha: 0.8),
                  widget.session.color.withValues(alpha: 0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.session.color.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.session.icon,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentInstruction() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Text(
        _currentStep < widget.session.script.length
            ? widget.session.script[_currentStep]
            : 'Meditation complete',
        style: GoogleFonts.poppins(
          fontSize: 18,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Text(
          '${(_secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: widget.session.color,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _currentStep / widget.session.script.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(widget.session.color),
        ),
        const SizedBox(height: 8),
        Text(
          'Step ${_currentStep + 1} of ${widget.session.script.length}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isPlaying ? _pauseMeditation : _startMeditation,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.session.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              const SizedBox(width: 8),
              Text(
                _isPlaying ? 'Pause' : 'Start',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
