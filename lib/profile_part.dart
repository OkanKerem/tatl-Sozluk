import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/utils/routes.dart';

class ProfilePart extends StatelessWidget {
  const ProfilePart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: AppFonts.entryBodyText.copyWith(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF5EFFF),
        child: const Center(
          child: Text('Profil sayfası'),
        ),
      ),
    );
  }
}
