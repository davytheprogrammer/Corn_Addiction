import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  final Function toggleView;
  const RegisterScreen({Key? key, required this.toggleView}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _error = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Clear previous errors
    setState(() => _error = '');

    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Create user account
        final UserCredential result =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Create user profile in Firestore
        if (result.user != null) {
          await _firestore.collection('users').doc(result.user!.uid).set({
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'userType': 'livestock_owner', // Set appropriate user type
            'isProfileComplete': false,
            'lastLogin': FieldValue.serverTimestamp(),
          });

          // User creation successful - navigation happens automatically with auth state change
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'This email is already registered. Please login instead.';
            break;
          case 'weak-password':
            errorMessage =
                'Password is too weak. Please use a stronger password.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'network-request-failed':
            errorMessage =
                'Network error. Please check your connection and try again.';
            break;
          default:
            errorMessage = e.message ?? 'An error occurred during registration';
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),

                  // Logo and branding section
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 120,
                      width: 120,
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
                        // Consider using SVG for better scaling
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // App name and tagline
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
                    'Modern Livestock Management',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Registration form title
                  Text(
                    'Create Your Account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email Field with improved design
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter an email';
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
                    hintText: 'Create a secure password',
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (val.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!val.contains(RegExp(r'[A-Z]'))) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!val.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primaryColor,
                        size: 22,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),

                  const SizedBox(height: 8),

                  // Password strength indicator
                  _buildPasswordStrengthIndicator(_passwordController.text),

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

                  // Register Button with modern design
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
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryColor.withOpacity(0.6),
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Account',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Login Link with enhanced design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
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
                          'Sign In',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Terms and privacy policy
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.02),
                ],
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

  Widget _buildPasswordStrengthIndicator(String password) {
    // Calculate password strength
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // Determine strength label and color
    final List<Color> colors = [
      Colors.grey.shade400, // Empty
      Colors.red.shade400, // Weak
      Colors.orange.shade400, // Medium
      Colors.lime.shade600, // Good
      Colors.green.shade600, // Strong
    ];

    final List<String> labels = [
      'Enter password',
      'Weak',
      'Medium',
      'Good',
      'Strong',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Progress indicator
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: password.isEmpty
                      ? Colors.grey.shade200
                      : index < strength
                          ? colors[strength]
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Strength label
        if (password.isNotEmpty)
          Text(
            labels[strength],
            style: TextStyle(
              color: colors[strength],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
