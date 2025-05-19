import 'package:flutter/material.dart';
// For File operations
// For handling network images
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Add Firestore import
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';

// User model class - updated to use profilePictureIndex
class User {
  String username;
  String email;
  String password;
  int profilePictureIndex; // Index of selected profile picture (1-5)
  List<String> followers;
  List<String> following;
  List<String> posts;

  User({
    required this.username,
    required this.email,
    required this.password,
    this.profilePictureIndex = 1, // Default to first picture
    this.followers = const [],
    this.following = const [],
    this.posts = const [],
  });

  // Convert user data to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nickname': username,
      'email': email,
      'profilePicture': profilePictureIndex,
      'followers': followers,
      'following': following,
      'posts': posts,
    };
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  int _selectedProfilePicture = 1; // Default to first picture
  bool _isLoading = false;

  // List of available asset images for avatars
  final List<String> _avatarAssets = [
    'assets/Images/boyAvatar.png',
    'assets/Images/girlAvatar.png',
    'assets/Images/pp1.png',
    'assets/Images/pp2.png',
    'assets/Images/pp3.png',
  ];

  // Function to handle profile photo selection
  void _handleProfilePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Profile Photo', style: AppFonts.infoLabelText),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _avatarAssets.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfilePicture = index + 1; // 1-based index
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _selectedProfilePicture == index + 1
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_avatarAssets[index]),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppFonts.entryBodyText),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Create user in Firebase Authentication
        final userCredential = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Create user object with additional data
        final user = User(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          profilePictureIndex: _selectedProfilePicture,
          followers: [],
          following: [],
          posts: [],
        );

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toMap());
            
        // Load user data into provider
        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false).loadUserData();
          Navigator.pushReplacementNamed(context, '/main_page');
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error: ${e.toString()}';
          
          // Check for Firebase Auth errors
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'This email is already registered. Please use a different email or login to your existing account.';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak. Please use a stronger password.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Please enter a valid email address.';
          } else if (e.toString().contains('network-request-failed')) {
            errorMessage = 'Network error. Please check your internet connection and try again.';
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0E6FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 50,
                left: 32,
                right: 32,
                bottom: 24
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Welcome title - centered like in ProfilePage
                    SizedBox(
                      width: screenSize.width,
                      child: Text(
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

                    // Please sign in subtitle
                    SizedBox(
                      width: screenSize.width,
                      child: Text(
                        'Please sign in',
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

                    // Username field with positioning similar to profile entries
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('username', style: AppFonts.infoLabelText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: screenSize.width - 64, // Match the 32px padding on both sides
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7), // Reduced opacity from 0.7 to 0.3
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        style: AppFonts.usernameText,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          else if(value.length < 3) return "Username too short";
                          else if (value.contains(' ')) return "No spaces allowed";
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('email', style: AppFonts.infoLabelText),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: screenSize.width - 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7), // Reduced opacity from 0.7 to 0.3
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: AppFonts.usernameText,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        }
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
                        color: Colors.white.withOpacity(0.7), // Reduced opacity from 0.7 to 0.3
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
                          else if (value.length < 6) return "Password too weak, must be longer than 6 characters.";
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Profile photo section
                    Text('profile photo', style: AppFonts.infoLabelText),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _handleProfilePhoto,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFDF1F1),
                            border: Border.all(
                              width: 1,
                              color: AppColors.primary,
                            ),
                            image: DecorationImage(
                              image: AssetImage(_avatarAssets[_selectedProfilePicture - 1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Sign in button with position adjusted for text
                    SizedBox(
                      width: screenSize.width - 64,
                      height: 48,
                      child: TextButton(
                        onPressed: _isLoading ? null : _validateAndSubmit,
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
                                'Sign Up',
                                style: AppFonts.deleteButtonText,
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // "I'm already signed, log in" text - positioned at the bottom with safe area
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate to login screen
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  "I'm already signed, log in",
                  style: AppFonts.entryBodyText.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
