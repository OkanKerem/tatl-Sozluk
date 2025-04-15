import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/utils/routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> entries = [
    {"title": "Entry Title", "body": "Entryi bla bla bla bla bla"},
    {"title": "Entry Title", "body": "Entryi bla bla bla bla bla"},
  ];

  void deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  void addEntry() {
    setState(() {
      entries.insert(0, {
        "title": "New Entry",
        "body": "NEw Entry..."
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 158,
            top: 50,
            child: Container(
              width: 95,
              height: 97,
              decoration: ShapeDecoration(
                color: const Color(0xFFFDF1F1),
                shape: const OvalBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 352,
            top: 8,

              child: IconButton(
                icon: Image.asset(
                  'assets/Images/settings_icon.png',
                  width: 50,
                  height: 50,
                ),
                onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },

                )

          ),
          Positioned(
            left: 184,
            top: 155,
            child: SizedBox(
              width: 137,
              height: 41,
              child: Text('Okan', style: AppFonts.usernameText),
            ),
          ),
          Positioned(left: 38, top: 217, child: Text('Following', style: AppFonts.infoLabelText)),
          Positioned(left: 169, top: 217, child: Text('Follower', style: AppFonts.infoLabelText)),
          Positioned(left: 293, top: 217, child: Text('Likes', style: AppFonts.infoLabelText)),
          Positioned(left: 74, top: 252, child: Text('0', style: AppFonts.countText)),
          Positioned(left: 198, top: 252, child: Text('0', style: AppFonts.countText)),
          Positioned(left: 306, top: 252, child: Text('0', style: AppFonts.countText)),
          Positioned(left: 32, top: 335, child: Text('Entries', style: AppFonts.entriesLabelText)),
          Positioned(
            left: 32,
            top: 371,
            child: Container(
              width: 341,
              height: 5,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 20,
            top: 320,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: addEntry,
              child: const Text("New Entry", style: TextStyle(fontFamily: 'Itim',color: Colors.white,fontSize: 16),),
            ),
          ),
          Positioned.fill(
            top: 390,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry['title']!, style: AppFonts.entryTitleText),
                          const SizedBox(height: 8),
                          Text(entry['body']!, style: AppFonts.entryBodyText),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => deleteEntry(index),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text("Delete", style: AppFonts.deleteButtonText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
