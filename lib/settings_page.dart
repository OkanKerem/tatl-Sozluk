import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 32),

            // Frame 1
            _buildSettingFrame(
              assetPath: 'assets/Images/pp_icon.png',
              text: 'Change Profile Picture',
            ),
            const SizedBox(height: 16),

            // Frame 2
            _buildSettingFrame(
              assetPath: 'assets/Images/nick_icon.png',
              text: 'Change Nickname',
            ),
            const SizedBox(height: 16),

            // Frame 3
            _buildSettingFrame(
              assetPath: 'assets/Images/log_out_icon.png',
              text: 'Log Out',
            ),
          ],
        ),
      ),
    );
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
        ],
      ),
    );
  }
}
