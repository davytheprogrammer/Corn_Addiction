import 'package:flutter/material.dart';
import 'package:corn_addiction/screens/home/home.dart';
import 'package:corn_addiction/core/theme/app_theme.dart';
import 'package:corn_addiction/core/constants/strings.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return HomePage which will handle the bottom navigation
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // Automatically use light/dark based on system
      home: const HomePage(),
    );
  }
}
