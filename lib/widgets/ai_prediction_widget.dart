import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_prediction_model.dart';
import '../services/ai_prediction_service.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../screens/ai_analysis_detail_screen.dart';

class AIPredictionWidget extends StatefulWidget {
  const AIPredictionWidget({super.key});

  @override
  State<AIPredictionWidget> createState() => _AIPredictionWidgetState();
}

class _AIPredictionWidgetState extends State<AIPredictionWidget>
    with TickerProviderStateMixin {
  final AIPredictionService _aiService = AIPredictionService();
  final AuthService _authService = AuthService();

  AIPredictionModel? _prediction;
  bool _isLoading = true;
  bool _isRefreshing = false;

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPrediction();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPrediction() async {
    print('🎯 AI Widget: _loadPrediction called');
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      print('🎯 AI Widget: Current user: ${user?.uid ?? 'null'}');
      if (user != null) {
        print('🎯 AI Widget: Calling AI service...');
        final prediction = await _aiService.getPrediction(user.uid);
        print(
            '🎯 AI Widget: Prediction received: ${prediction != null ? '${(prediction.temptationProbability * 100).round()}% risk' : 'null'}');
        if (mounted) {
          setState(() {
            _prediction = prediction;
            _isLoading = false;
          });

          if (prediction != null) {
            print('🎯 AI Widget: Starting progress animation');
            _progressController.forward();
          }
        }
      } else {
        print('🎯 AI Widget: No user found, cannot load prediction');
      }
    } catch (e) {
      print('🎯 AI Widget: Error loading prediction: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPrediction() async {
    print('🔄 AI Widget: _refreshPrediction called');
    if (_isRefreshing) {
      print('🔄 AI Widget: Already refreshing, skipping');
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final user = _authService.currentUser;
      print('🔄 AI Widget: Current user: ${user?.uid ?? 'null'}');
      if (user != null) {
        print('🔄 AI Widget: Calling forceRefresh...');
        final prediction = await _aiService.forceRefresh(user.uid);
        print(
            '🔄 AI Widget: ForceRefresh completed, prediction: ${prediction != null ? '${(prediction.temptationProbability * 100).round()}% risk' : 'null'}');
        if (mounted) {
          setState(() {
            _prediction = prediction;
            _isRefreshing = false;
          });

          _progressController.reset();
          if (prediction != null) {
            print('🔄 AI Widget: Starting progress animation after refresh');
            _progressController.forward();
          }
        }
      } else {
        print('🔄 AI Widget: No user found for refresh');
      }
    } catch (e) {
      print('🔄 AI Widget: Error refreshing prediction: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Color _getRiskColor(double probability) {
    if (probability >= 0.7) return const Color(0xFFE53E3E); // Red
    if (probability >= 0.4) return const Color(0xFFED8936); // Orange
    return const Color(0xFF38A169); // Green
  }

  IconData _getRiskIcon(double probability) {
    if (probability >= 0.7) return Icons.warning_rounded;
    if (probability >= 0.4) return Icons.info_rounded;
    return Icons.check_circle_rounded;
  }

  String _formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chances of Relapse',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Analyzing your patterns...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionContent() {
    if (_prediction == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load prediction',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final riskColor = _getRiskColor(_prediction!.temptationProbability);
    final riskIcon = _getRiskIcon(_prediction!.temptationProbability);

    return GestureDetector(
      onTap: () {
        // Navigate to detailed analysis page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIAnalysisDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          _prediction!.isHighRisk ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          riskIcon,
                          color: riskColor,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chances of Relapse',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _prediction!.riskLevelText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _refreshPrediction();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Compact percentage display
            Center(
              child: Column(
                children: [
                  Text(
                    _formatPercentage(_prediction!.temptationProbability),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Risk Level',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value *
                        _prediction!.temptationProbability,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            riskColor.withValues(alpha: 0.7),
                            riskColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Tap to view more
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap for detailed analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Last Updated
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.grey.shade400,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_getTimeAgo(_prediction!.timestamp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return _buildPredictionContent();
  }
}
