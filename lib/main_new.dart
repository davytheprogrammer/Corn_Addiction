import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:corn_addiction/wrapper.dart';
import 'package:corn_addiction/theme_new.dart';

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

  // Set to portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
  const RecoveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Corn Addiction',
      theme: CornAddictionTheme.lightTheme,
      darkTheme: CornAddictionTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AnimatedBackground(
        child: Wrapper(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Animation controller setup helper
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool reducedMotion;

  const AnimatedBackground({
    Key? key,
    required this.child,
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
              painter: ModernBackgroundPainter(),
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
