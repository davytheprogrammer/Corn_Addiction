import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  final Function(bool) onAuthSelect;
  const WelcomeScreen({Key? key, required this.onAuthSelect}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;

  bool _isOffline = false;
  bool _previouslyLoggedIn = false;
  bool _loadingPrefs = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);
  final ScrollController _scrollController = ScrollController();

  // For the feature dots indicator
  final PageController _featurePageController = PageController();
  int _currentFeaturePage = 0;
  Timer? _autoScrollTimer;

  final List<FeatureItem> _features = [
    FeatureItem(
      title: 'AI-Powered Diagnostics',
      description:
          'Advanced machine learning models for early disease detection',
      iconData: Icons.pets,
    ),
    FeatureItem(
      title: 'Real-time Monitoring',
      description: 'Track vital health metrics of your animals 24/7',
      iconData: Icons.monitor_heart,
    ),
    FeatureItem(
      title: 'Expert Insights',
      description: 'Access veterinary-backed analysis and recommendations',
      iconData: Icons.psychology,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSystemUI();
    _checkConnectivity();
    _loadLoginState();
    _setupScrollListener();
    _setupAutoScroll();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _contentController.forward();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isOffline = connectivityResult == ConnectivityResult.none;
      });

      // Listen for connectivity changes
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((result) {
        setState(() {
          _isOffline = result == ConnectivityResult.none;
        });
      }) as StreamSubscription<ConnectivityResult>?;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  Future<void> _loadLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _previouslyLoggedIn = prefs.getBool('previously_logged_in') ?? false;
        _loadingPrefs = false;
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      setState(() {
        _loadingPrefs = false;
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final progress = _scrollController.offset /
            (_scrollController.position.maxScrollExtent * 0.8);
        _scrollProgress.value = progress.clamp(0.0, 1.0);
      }
    });
  }

  void _setupAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_featurePageController.hasClients) {
        if (_currentFeaturePage < _features.length - 1) {
          _currentFeaturePage++;
        } else {
          _currentFeaturePage = 0;
        }

        _featurePageController.animateToPage(
          _currentFeaturePage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    _featurePageController.dispose();
    _connectivitySubscription?.cancel();
    _autoScrollTimer?.cancel();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernBackgroundPainter(
                  animation: _backgroundAnimation.value,
                  primaryColor: primaryColor,
                ),
                child: Container(),
              );
            },
          ),

          // Content Layer
          _loadingPrefs
              ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
              : SafeArea(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 60.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHeader(primaryColor),
                      const SizedBox(height: 24),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildFeatureCarousel(primaryColor, surfaceColor),
                      const SizedBox(height: 40),
                      _buildWelcomeMessage(primaryColor, surfaceColor),
                      const SizedBox(height: 40),
                      _buildAuthButtons(primaryColor, onPrimaryColor),
                      const SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),

          // Offline Indicator
          if (_isOffline)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    // Get current date instead of using hardcoded value
    final now = DateTime.now();
    final formattedDate = _formatDate(now);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          formattedDate,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$month $day, $year';
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AniWise',
          style: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Intelligent Animal Care',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
          curve: Curves.easeOutQuint,
        );
  }

  Widget _buildFeatureCarousel(Color primaryColor, Color surfaceColor) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _featurePageController,
            itemCount: _features.length,
            onPageChanged: (index) {
              setState(() {
                _currentFeaturePage = index;
              });
            },
            itemBuilder: (context, index) {
              final feature = _features[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature.iconData,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feature.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    duration: 400.ms,
                    delay: (index * 100).ms,
                  );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _features.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentFeaturePage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentFeaturePage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage(Color primaryColor, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome to the Future of Animal Care',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'AniWise leverages AI technology to revolutionize how you monitor, diagnose, and care for your animals. Join our community of innovative farmers and veterinary professionals.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Over 10,000 animals monitored',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(
          begin: 50,
          end: 0,
          duration: 800.ms,
          delay: 300.ms,
          curve: Curves.easeOutQuint,
        );
  }

  Widget _buildAuthButtons(Color primaryColor, Color onPrimaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _previouslyLoggedIn
            ? _buildWelcomeBackButton(primaryColor, onPrimaryColor)
            : _buildLoginButtons(primaryColor, onPrimaryColor),
      ],
    ).animate().fadeIn(duration: 800.ms, delay: 500.ms).slideY(
          begin: 50,
          end: 0,
          duration: 800.ms,
          delay: 500.ms,
          curve: Curves.easeOutQuint,
        );
  }

  Widget _buildWelcomeBackButton(Color primaryColor, Color onPrimaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome back, davytheprogrammer!',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.onAuthSelect(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue to Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => widget.onAuthSelect(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Use Another Account',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(Color primaryColor, Color onPrimaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => widget.onAuthSelect(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Log In',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => widget.onAuthSelect(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Create Account',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            'By continuing, you agree to our',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Terms of Service'),
              Text(
                ' and ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              _buildFooterLink('Privacy Policy'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'v2.3.1 • © 2025 AniWise',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective page
      },
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;

  ModernBackgroundPainter(
      {required this.animation, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0D4D28),
        const Color(0xFF0F6634),
        const Color(0xFF084D2A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final backgroundPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw animated patterns
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    // Draw circles
    for (int i = 0; i < 20; i++) {
      final progress = animation;
      final offset = i * (math.pi / 10);
      final x =
          size.width * (0.1 + 0.8 * ((math.sin(progress + offset) + 1) / 2));
      final y = size.height *
          (0.1 + 0.8 * ((math.cos(progress * 0.7 + offset) + 1) / 2));
      final radius =
          size.width * 0.05 * ((math.sin(progress * 1.2 + offset) + 1.5) / 2.5);

      canvas.drawCircle(Offset(x, y), radius, patternPaint);
    }

    // Draw flowing lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pathCount = 5;
    for (int i = 0; i < pathCount; i++) {
      final path = Path();
      final startY = size.height * (i / pathCount);

      path.moveTo(0, startY);

      for (double x = 0; x <= size.width; x += size.width / 20) {
        final offset = i * 0.5;
        final normalizedX = x / size.width;
        final y = startY +
            size.height * 0.1 * math.sin(normalizedX * 6 + animation + offset);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(ModernBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class FeatureItem {
  final String title;
  final String description;
  final IconData iconData;

  FeatureItem({
    required this.title,
    required this.description,
    required this.iconData,
  });
}
