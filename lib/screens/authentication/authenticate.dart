// authenticate.dart
import 'package:flutter/material.dart';

import 'login.dart';
import 'register.dart';
import 'welcome.dart';


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
      return WelcomeScreen(
        onAuthSelect: onAuthSelect,
        key: const ValueKey('welcome'),
      );
    } else if (showSignIn) {
      return LoginScreen(
        toggleView: toggleView,
        key: const ValueKey('login'),
      );
    } else {
      return RegisterScreen(
        toggleView: toggleView,
        key: const ValueKey('register'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: const AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.9),
                BlendMode.lighten,
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
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
      ],
    );
  }
}
