import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:corn_addiction/core/theme/app_theme.dart';
import 'package:corn_addiction/core/constants/colors.dart';
import 'package:corn_addiction/app.dart';
import 'package:corn_addiction/wrapper.dart';

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

  // Set portrait orientation only
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

class RecoveryApp extends StatelessWidget {
  const RecoveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corn Addiction',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
