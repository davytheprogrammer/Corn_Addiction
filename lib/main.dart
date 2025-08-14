import 'package:corn_addiction/utils/texture_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/providers/auth_provider.dart';
import 'package:corn_addiction/app.dart';
import 'package:corn_addiction/wrapper.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String app = '/app';
  static const String wrapper = '/wrapper';
  static const String home = '/home';
  static const String tracking = '/tracking';
  static const String insights = '/insights';
  static const String community = '/community';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String journal = '/journal';
  static const String resources = '/resources';
  static const String meditations = '/meditations';
  static const String challenges = '/challenges';
  static const String accountSettings = '/account-settings';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI preferences for a more immersive experience
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

  // Reduce texture memory pressure
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize texture optimization
  TextureManager.optimizeImageCache();

  try {
    await Firebase.initializeApp();
    runApp(const ProviderScope(child: RecoveryApp()));
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Still run the app even if Firebase fails
    runApp(const ProviderScope(child: RecoveryApp()));
  }
}

class RecoveryApp extends ConsumerWidget {
  const RecoveryApp({super.key});

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CornAddiction',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.light, // Default to light theme
      initialRoute: Routes.wrapper,
      routes: {
        Routes.wrapper: (context) => AnimatedBackground(
              primaryColor: AppColors.primary,
              child: const Wrapper(),
            ),
        Routes.app: (context) => const App(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Animation controller setup helper
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final bool reducedMotion;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.primaryColor,
    this.reducedMotion = false,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30), // Increased for smoother animation
      vsync: this,
    );

    if (!widget.reducedMotion) {
      _backgroundController.repeat();
    } else {
      _backgroundController.value = 0.5; // Fixed position for reduced motion
    }

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // 2π
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Animated Background
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: ModernBackgroundPainter(
                animation: _backgroundAnimation.value,
                primaryColor: widget.primaryColor,
              ),
              child: Container(),
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;

  ModernBackgroundPainter({
    required this.animation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.gradientStart,
        AppColors.gradientEnd,
        AppColors.primary,
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
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    // Draw animated circles with improved depth
    for (int i = 0; i < 20; i++) {
      final progress = animation;
      final offset = i * (3.14159 / 10);
      final x = size.width * (0.1 + 0.8 * ((sin(progress + offset) + 1) / 2));
      final y =
          size.height * (0.1 + 0.8 * ((cos(progress * 0.7 + offset) + 1) / 2));
      final radius =
          size.width * 0.05 * ((sin(progress * 1.2 + offset) + 1.5) / 2.5);

      // Add depth with a subtle shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.04)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x + 2, y + 2), radius, shadowPaint);
      canvas.drawCircle(Offset(x, y), radius, patternPaint);
    }

    // Draw enhanced flowing lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pathCount = 6; // Increased from 5 to 6
    for (int i = 0; i < pathCount; i++) {
      final path = Path();
      final startY = size.height * (i / pathCount);

      path.moveTo(0, startY);

      for (double x = 0; x <= size.width; x += size.width / 25) {
        // Increased detail
        final offset = i * 0.5;
        final normalizedX = x / size.width;
        final y = startY +
            size.height * 0.1 * sin(normalizedX * 6 + animation + offset);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, linePaint);
    }

    // Add subtle particle effect
    final random = Random(42); // Fixed seed for consistency
    final particlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final particleRadius = 1.0 + random.nextDouble() * 1.5;
      final opacity = 0.1 + random.nextDouble() * 0.3;

      particlePaint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
          Offset(x + sin(animation * 0.5 + i) * 2,
              y + cos(animation * 0.7 + i) * 2),
          particleRadius,
          particlePaint);
    }
  }

  @override
  bool shouldRepaint(ModernBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.primaryColor != primaryColor;

  // Math helpers for the background
  double sin(double x) => math.sin(x);
  double cos(double x) => math.cos(x);
}

class BackgroundWrapper extends ConsumerWidget {
  const BackgroundWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return AnimatedBackground(
      primaryColor: AppColors.primary,
      child: authState.when(
        data: (user) => const Wrapper(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Authentication Error')),
      ),
    );
  }
}

class BackgroundPage extends StatelessWidget {
  final Widget child;

  const BackgroundPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      primaryColor: AppColors.primary,
      child: child,
    );
  }
}
