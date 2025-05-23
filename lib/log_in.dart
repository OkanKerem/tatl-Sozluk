import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signInWithEmailAndPassword(
          _usernameOrEmailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main_page');
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error: ${e.toString()}';
          
          // Check for Firebase Auth errors related to user not existing
          if (e.toString().contains('user-not-found') || 
              e.toString().contains('invalid-credential') ||
              e.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
            errorMessage = 'This profile was not found. Email or password is incorrect.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0E6FF), // Light purple background
      body: Stack(
        children: [
          // Form in a scrollable container for iPhone compatibility
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 90, left: 32, right: 32, bottom: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Welcome title - centered like in the screenshot
                    SizedBox(
                      width: screenSize.width,
                      child: const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Please log in subtitle
                    SizedBox(
                      width: screenSize.width,
                      child: const Text(
                        'Please log in',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Username or email field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email', style: AppFonts.infoLabelText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: screenSize.width - 64, // Match the 32px padding on both sides
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _usernameOrEmailController,
                        style: AppFonts.usernameText,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          // Email format validation
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password', style: AppFonts.infoLabelText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: screenSize.width - 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        style: AppFonts.usernameText,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Log in button - using same styling as buttons in profile page
                    SizedBox(
                      width: screenSize.width - 64,
                      height: 48,
                      child: TextButton(
                        onPressed: _isLoading ? null : _login,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Log in',
                                style: AppFonts.deleteButtonText,
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // "Don't have an account?" text
                    GestureDetector(
                      onTap: () {
                        // Navigate to sign in screen
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: Text(
                        "Don't have an account?",
                        style: AppFonts.entryBodyText.copyWith(
                          decoration: TextDecoration.underline,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
