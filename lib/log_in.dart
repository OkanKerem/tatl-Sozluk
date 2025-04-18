import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/user_model.dart';
import 'package:tatli_sozluk/user_service.dart';

// delete later

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  // In _login method of LoginPage
  void _login() async {
  if (_formKey.currentState!.validate()) {
    // Get username/email and password
    final usernameOrEmail = _usernameOrEmailController.text;
    final password = _passwordController.text;
    
    print('Attempting login with: $usernameOrEmail');
    
    // Verify credentials
    User? user = await UserService.login(usernameOrEmail, password);
    
    if (user != null) {
      // Login successful, navigate to profile
      print('Login successful!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacementNamed(context, '/profile', arguments: user);
    } else {
      // Invalid credentials
      print('Login failed: Invalid credentials');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username/email or password')),
      );
    }
  } else {
    // Form validation failed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please check the form and try again')),
    );
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
                      child: Text('username or email', style: AppFonts.infoLabelText),
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
                            return 'Username or email is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('password', style: AppFonts.infoLabelText),
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
                        onPressed: _login,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'log in',
                          style: AppFonts.deleteButtonText, // Using your delete button text style for consistency
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // "Didn't sign in?" text
                    GestureDetector(
                      onTap: () {
                        // Navigate to sign in screen
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: Text(
                        "Didn't sign in?",
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


