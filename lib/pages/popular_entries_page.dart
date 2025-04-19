import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class PopularEntriesPage extends StatelessWidget {
  const PopularEntriesPage({super.key});

  final List<Map<String, dynamic>> entries = const [
    {'text': "çayı şekersiz içmek", 'count': 155},
    {'text': "tek başına sinema", 'count': 128},
    {'text': "çamaşırdan gelen sabun kokusu", 'count': 111},
    {'text': "pencereden gelen rüzgar", 'count': 90},
    {'text': "yağmur sonrası yürüyüş", 'count': 82},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Popular Entries",
                style: AppFonts.entryTitleText.copyWith(fontSize: 24),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "most liked entries recently",
                style: AppFonts.entryBodyText.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry['text'],
                            style: AppFonts.entryBodyText.copyWith(fontSize: 15),
                          ),
                        ),
                        Text(
                          '${entry['count']}',
                          style: AppFonts.entryBodyText.copyWith(
                            fontSize: 15,
                            color: const Color(0xFFCDCDCD),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

