import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class RandomEntryPage extends StatelessWidget {
  const RandomEntryPage({super.key});

  final List<String> entryTexts = const [
    "sabah kahvesi kokusu",
    "temiz çarşafa uzanmak",
    "güzel bir mesaj almak",
    "akşam yürüyüşü",
    "çalan sevdiğin bir şarkı",
    "sıcak duş",
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Random Entry',
          style: AppFonts.entryTitleText.copyWith(fontSize: 24, color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "simple things that make you happy",
                style: AppFonts.entryBodyText.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: entryTexts.length,
                itemBuilder: (context, index) {
                  final text = entryTexts[index];
                  final count = random.nextInt(300);
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
                            text,
                            style: AppFonts.entryBodyText.copyWith(fontSize: 15),
                          ),
                        ),
                        Text(
                          '$count',
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
