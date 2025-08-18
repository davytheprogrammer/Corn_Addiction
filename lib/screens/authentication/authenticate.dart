// authenticate.dart
import 'package:flutter/material.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'modern_login.dart';
import 'modern_register.dart';
import 'modern_welcome.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  AuthenticateState createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate>
    with SingleTickerProviderStateMixin {
  bool showSignIn = true;
  bool showWelcome = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
      _controller.reset();
      _controller.forward();
    });
  }

  void onAuthSelect(bool isLogin) {
    setState(() {
      showWelcome = false;
      showSignIn = isLogin;
      _controller.reset();
      _controller.forward();
    });
  }

  Widget _buildCurrentScreen() {
    if (showWelcome) {
      return ModernWelcomeScreen(
        onAuthSelect: onAuthSelect,
        key: const ValueKey('welcome'),
      );
    } else if (showSignIn) {
      return ModernLoginScreen(
        toggleView: toggleView,
        key: const ValueKey('login'),
      );
    } else {
      return ModernRegisterScreen(
        toggleView: toggleView,
        key: const ValueKey('register'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.surfaceVariant,
          ],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _buildCurrentScreen(),
      ),
    );
  }
}
