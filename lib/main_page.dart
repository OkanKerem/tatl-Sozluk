import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/utils/routes.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  void _navigateToRandomEntry(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.routes.keys.firstWhere((r) => r == '/entry_detail'));
  }

  void _navigateToEntryDetail(BuildContext context, String title) {
    Navigator.pushNamed(context, AppRoutes.routes.keys.firstWhere((r) => r == '/entry_detail'),
        arguments: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5EFFF),
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 61,
              child: Row(
                children: [
                  _buildFilterButton('today', isSelected: true),
                  const SizedBox(width: 16),
                  _buildFilterButton('news'),
                  const SizedBox(width: 16),
                  _buildFilterButton('top'),
                  const SizedBox(width: 16),
                  _buildFilterButton('follows'),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 112,
              right: 0,
              bottom: 80,
              child: ListView(
                children: [
                  _buildTopicItem(context, 'who wants to be a millionaire', '125'),
                  _buildTopicItem(context, 'midnight at pera palas', '30'),
                  _buildTopicItem(context, "tatlı sözlük's database of people to chat", '199'),
                  _buildTopicItem(context, 'simple things that make you happy', '280', isHighlighted: true),
                  _buildTopicItem(context, 'sapiosexual', '57'),
                  _buildTopicItem(context, "driver's license fee Rising to 10,000 Lira", '23'),
                  _buildTopicItem(context, 'arda güler', '12'),
                  _buildTopicItem(context, 'january 2023 civil servant salary increase', '10'),
                  _buildTopicItem(context, 'sitting alone in a café', '5'),
                  _buildTopicItem(context, 'a mother monkey bathing her baby', '7'),
                  _buildTopicItem(context, 'december 11 serbian foreign affairs statement', '20'),
                  _buildTopicItem(context, 'post a cat picture for the night', '32'),
                  _buildTopicItem(context, 'seagull 1963', '55'),
                  _buildTopicItem(context, 'judgment (tv series)', '221'),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: AppColors.primary,
                      onPressed: () => Navigator.pushNamed(context, '/search'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      color: AppColors.primary,
                      onPressed: () => _navigateToRandomEntry(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.message),
                      color: AppColors.primary,
                      onPressed: () => Navigator.pushNamed(context, '/dm'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      color: AppColors.primary,
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, {bool isSelected = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: ShapeDecoration(
      color: isSelected ? const Color(0xFF262626) : const Color(0xFFF6F5FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Text(text, style: AppFonts.entryBodyText.copyWith(color: isSelected ? const Color(0xFFF5EFFF) : const Color(0xFF646464), fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400)),
  );

  Widget _buildTopicItem(BuildContext context, String title, String count, {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () => _navigateToEntryDetail(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(color: isHighlighted ? const Color(0xFFF6F5FA) : Colors.transparent),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [Expanded(child: Text(title, style: AppFonts.entryBodyText.copyWith(color: const Color(0xFF010120)))), SizedBox(width: 36, child: Text(count, textAlign: TextAlign.right, style: AppFonts.entryBodyText.copyWith(color: const Color(0xFFCDCDCD))))]),
      ),
    );
  }
}
