import 'package:flutter/material.dart';
import 'dart:io';  // For File operations
import 'package:flutter_cache_manager/flutter_cache_manager.dart';  // For handling network images

// Using your utility classes
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';



// User model class - updated to include profilePhotoUrl and assetImagePath
class User {
  String username;
  String email;
  String password;
  File? profilePhoto;
  String? profilePhotoUrl; // For network images
  String? assetImagePath; // For asset images

  User({
    required this.username, 
    required this.email,
    required this.password,
    this.profilePhoto,
    this.profilePhotoUrl,
    this.assetImagePath,
  });
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
  File? _profileImage;
  String? _imageUrl; // To store network image URL
  String? _assetImagePath; // To store asset image path
  bool _isNetworkImage = false;
  bool _isAssetImage = false;

  // List of available asset images for avatars
  final List<String> _avatarAssets = [
    'assets/avatars/girlAvatar.png', 
    'assets/avatars/boyAvatar.png'
  ];

  // Function to handle profile photo selection
  void _handleProfilePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Profile Photo', style: AppFonts.infoLabelText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text('Use network image', style: AppFonts.entryBodyText),
              onTap: () {
                Navigator.pop(context);
                _showNetworkImageDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: Text('Choose avatar', style: AppFonts.entryBodyText),
              onTap: () {
                Navigator.pop(context);
                _showAvatarSelectionDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog for entering a network image URL
  void _showNetworkImageDialog() {
    final TextEditingController urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Image URL', style: AppFonts.infoLabelText),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://example.com/image.jpg',
              hintStyle: AppFonts.entryBodyText.copyWith(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.entryBodyText),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  if (url.startsWith('http')) {
                    try {
                      // Download and cache the network image
                      final fileInfo = await DefaultCacheManager().downloadFile(url);
                      setState(() {
                        _profileImage = fileInfo.file;
                        _imageUrl = url;
                        _isNetworkImage = true;
                        _isAssetImage = false;
                        _assetImagePath = null;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load image: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid URL starting with http:// or https://')),
                    );
                  }
                }
              },
              child: Text('OK', style: AppFonts.entryBodyText),
            ),
          ],
        );
      },
    );
  }

  // Dialog for selecting an avatar from assets
  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Avatar', style: AppFonts.infoLabelText),
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
                      _assetImagePath = _avatarAssets[index];
                      _isAssetImage = true;
                      _isNetworkImage = false;
                      _imageUrl = null;
                      _profileImage = null;
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_avatarAssets[index]),
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
        );
      },
    );
  }

  // Validate form and submit
  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) { 
      // Form is valid, create user object and proceed
      final user = User(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        profilePhoto: _isNetworkImage ? _profileImage : null,
        profilePhotoUrl: _isNetworkImage ? _imageUrl : null,
        assetImagePath: _isAssetImage ? _assetImagePath : null,
      );
      
      Navigator.pushReplacementNamed(context, '/');  // Navigate to main page
    } else {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Please check the form and try again')),  
      );
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
      backgroundColor:const Color(0xFFF0E6FF), // Using color from utility class
      body: Stack(  
        children: [
          // Form in a scrollable container for iPhone compatibility
          Positioned.fill(
            child: SingleChildScrollView(  
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 50, // Account for safe area
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
                            image: _isAssetImage && _assetImagePath != null
                                ? DecorationImage(
                                    image: AssetImage(_assetImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : _isNetworkImage && _imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: (!_isAssetImage && !_isNetworkImage)
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Sign in button with position adjusted for text
                    SizedBox(
                      width: screenSize.width - 64,
                      height: 48,
                      child: TextButton(
                        onPressed: _validateAndSubmit,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding to center text better
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'sign in',
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
