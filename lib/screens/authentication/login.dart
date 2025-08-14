import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleView;
  const LoginScreen({Key? key, required this.toggleView}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _error = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    // Check for saved credentials
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
    } else {
      await prefs.remove('saved_email');
    }
  }

  Future<void> _login() async {
    // Clear previous errors
    setState(() => _error = '');

    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Authenticate user
        final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save credentials if "Remember me" is checked
        await _saveCredentials();

        // Update user's last login timestamp
        if (result.user != null) {
          await _firestore.collection('users').doc(result.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        // Login successful - navigation happens automatically with auth state change
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email. Please register.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'user-disabled':
            errorMessage =
                'This account has been disabled. Please contact support.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Too many failed login attempts. Please try again later.';
            break;
          case 'network-request-failed':
            errorMessage =
                'Network error. Please check your connection and try again.';
            break;
          default:
            errorMessage =
                e.message ?? 'Failed to login. Please check your credentials.';
        }

        setState(() {
          _error = errorMessage;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again later.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _error = 'Please enter your email address to reset your password.';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _error = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      // Show success dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Failed to send password reset email.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Design system colors
    final primaryColor = Color(0xFF2E7D32); // Deep green
    final secondaryColor = Color(0xFF66BB6A); // Medium green
    final backgroundColor = Color(0xFFF5F9F6); // Light green-tinted background
    final textColor = Color(0xFF1B5E20); // Dark green for text

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.06),

                    // Logo and branding section
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // App name and welcome message
                    Text(
                      'AniWise',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Welcome back!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to your livestock management dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: size.height * 0.05),

                    // Email Field with improved design
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primaryColor,
                          size: 22,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Please enter your password'
                          : null,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),

                    const SizedBox(height: 16),

                    // Remember me checkbox and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember me
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                    () => _rememberMe = value ?? false),
                                activeColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        // Forgot password button
                        TextButton(
                          onPressed: _resetPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Error Text with improved styling
                    if (_error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error,
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_error.isNotEmpty) const SizedBox(height: 24),

                    // Login Button with modern design
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _loading
                            ? []
                            : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primaryColor.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.login_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Register Link with enhanced design
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: textColor.withOpacity(0.8)),
                        ),
                        TextButton(
                          onPressed: () => widget.toggleView(),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required FormFieldValidator<String> validator,
    required Color primaryColor,
    required Color secondaryColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
        prefixIcon: Icon(prefixIcon, color: primaryColor, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        errorStyle: TextStyle(color: Colors.red.shade700),
      ),
      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
