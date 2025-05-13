import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // List of available avatars - must match the sign_in.dart list
  final List<String> _avatarAssets = [
    'assets/Images/girlAvatar.png',
    'assets/Images/boyAvatar.png',
    'assets/Images/girlAvatar.png',
    'assets/Images/boyAvatar.png',
    'assets/Images/boyAvatar.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 32),

                // Frame 1 - Change Profile Picture
                GestureDetector(
                  onTap: _showChangeProfilePictureDialog,
                  child: _buildSettingFrame(
                    assetPath: 'assets/Images/pp_icon.png',
                    text: 'Change Profile Picture',
                  ),
                ),
                const SizedBox(height: 16),

                // Frame 2 - Change Nickname
                GestureDetector(
                  onTap: _showChangeNicknameDialog,
                  child: _buildSettingFrame(
                    assetPath: 'assets/Images/nick_icon.png',
                    text: 'Change Nickname',
                  ),
                ),
                const SizedBox(height: 16),

                // Frame 3 - Log Out
                GestureDetector(
                  onTap: _logOut,
                  child: _buildSettingFrame(
                    assetPath: 'assets/Images/log_out_icon.png',
                    text: 'Log Out',
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Change profile picture dialog
  void _showChangeProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Profile Picture', style: AppFonts.infoLabelText),
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
                  Navigator.pop(context);
                  _updateProfilePicture(index + 1); // 1-based index
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
      ),
    );
  }

  // Update profile picture with Provider
  Future<void> _updateProfilePicture(int pictureIndex) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Provider to update profile picture
      bool success = await Provider.of<UserProvider>(context, listen: false)
          .updateProfilePicture(pictureIndex);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Change nickname dialog
  void _showChangeNicknameDialog() {
    final TextEditingController _nicknameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Nickname', style: AppFonts.infoLabelText),
        content: TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: 'Enter new nickname',
            hintStyle: AppFonts.entryBodyText.copyWith(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppFonts.entryBodyText),
          ),
          TextButton(
            onPressed: () {
              if (_nicknameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _updateNickname(_nicknameController.text.trim());
              }
            },
            child: Text('Save', style: AppFonts.entryBodyText),
          ),
        ],
      ),
    );
  }

  // Update nickname with Provider
  Future<void> _updateNickname(String newNickname) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Provider to update nickname
      bool success = await Provider.of<UserProvider>(context, listen: false)
          .updateUsername(newNickname);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nickname updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating nickname: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Log out user with Provider
  Future<void> _logOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Provider to sign out
      await Provider.of<UserProvider>(context, listen: false).signOut();
      
      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child:const Icon(Icons.arrow_back, size: 28)
          ),
          const SizedBox(width: 16),
          Text(
            'Ayarlar',
            style: AppFonts.usernameText.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingFrame({required String assetPath, required String text}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: AppFonts.entryTitleText,
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
