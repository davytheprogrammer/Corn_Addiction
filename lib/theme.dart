import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

// Define app colors
class AppColors {
  static const Color gradientStart = Color(0xFF2E7D32);
  static const Color gradientEnd = Color(0xFF1B5E20);
  static const Color learningHubGradient1 = Color(0xFF388E3C);
}

class CornAddictionTheme {
  // Colors
  static const Color primary = Color(0xFF2E7D32); // Deep green
  static const Color primaryLight = Color(0xFF66BB6A); // Light green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark green
  static const Color accent = Color(0xFFF57C00); // Orange
  static const Color background =
      Color(0xFFF5F9F6); // Light green-tinted background
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color success = Color(0xFF388E3C); // Green
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color info = Color(0xFF1976D2); // Blue
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF212121);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white;
  static const Color darkOnBackground = Colors.white;

  // Text styles
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    ),
  );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: accent,
        onSecondary: Colors.white,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withValues(alpha: 0.32);
          }
          return primary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withValues(alpha: 0.32);
          }
          return primary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withValues(alpha: 0.32);
          }
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withValues(alpha: 0.12);
          }
          if (states.contains(MaterialState.selected)) {
            return primary.withValues(alpha: 0.5);
          }
          return Colors.grey.withValues(alpha: 0.5);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white, width: 3),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),
      ),
      dividerColor: Colors.grey.shade200,
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        onPrimary: onSurface,
        secondary: accent,
        onSecondary: onSurface,
        background: darkBackground,
        onBackground: darkOnBackground,
        surface: darkSurface,
        onSurface: darkOnSurface,
        error: error,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(
        bodyColor: darkOnSurface,
        displayColor: darkOnSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: darkSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: onSurface,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: onSurface,
          elevation: 2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade300),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withValues(alpha: 0.32);
          }
          return primaryLight;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          }
          return primaryLight;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.32);
          }
          if (states.contains(MaterialState.selected)) {
            return primaryLight;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(.12);
          }
          if (states.contains(MaterialState.selected)) {
            return primaryLight.withOpacity(.5);
          }
          return Colors.grey.withOpacity(.5);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: primaryLight, width: 3),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade900,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryLight);
          }
          return const IconThemeData(color: Colors.grey);
        }),
      ),
      dividerColor: Colors.grey.shade800,
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
        AppColors.gradientStart,
        AppColors.gradientEnd,
        AppColors.learningHubGradient1,
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
      ..color = Colors.white.withOpacity(0.09)
      ..style = PaintingStyle.fill;

    // Draw animated circles with improved depth
    for (int i = 0; i < 20; i++) {
      final progress = animation;
      final offset = i * (math.pi / 10);
      final x =
          size.width * (0.1 + 0.8 * ((math.sin(progress + offset) + 1) / 2));
      final y = size.height *
          (0.1 + 0.8 * ((math.cos(progress * 0.7 + offset) + 1) / 2));
      final radius =
          size.width * 0.05 * ((math.sin(progress * 1.2 + offset) + 1.5) / 2.5);

      // Add depth with a subtle shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.04)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x + 2, y + 2), radius, shadowPaint);
      canvas.drawCircle(Offset(x, y), radius, patternPaint);
    }

    // Draw enhanced flowing lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
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
            size.height * 0.1 * math.sin(normalizedX * 6 + animation + offset);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, linePaint);
    }

    // Add subtle particle effect
    final random = math.Random(42); // Fixed seed for consistency
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final particleRadius = 1.0 + random.nextDouble() * 1.5;
      final opacity = 0.1 + random.nextDouble() * 0.3;

      particlePaint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(
          Offset(x + math.sin(animation * 0.5 + i) * 2,
              y + math.cos(animation * 0.7 + i) * 2),
          particleRadius,
          particlePaint);
    }
  }

  @override
  bool shouldRepaint(ModernBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.primaryColor != primaryColor;
}

// Animation controller setup helper
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final bool reducedMotion;

  const AnimatedBackground({
    Key? key,
    required this.child,
    required this.primaryColor,
    this.reducedMotion = false,
  }) : super(key: key);

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
      end: 2 * math.pi,
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
