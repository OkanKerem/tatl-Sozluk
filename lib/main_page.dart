import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/pages/random_entry_page.dart';
import 'package:tatli_sozluk/pages/popular_entries_page.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/entry_detail.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  void _navigateToRandom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RandomEntryPage()),
    );
  }

  void _navigateToNew(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  void _navigateToPopular(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PopularEntriesPage()),
    );
  }

  void _navigateToEntryDetail(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EntryDetailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5EFFF),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Top navigation buttons: New, Random, Popular
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => _navigateToNew(context),
                    child: Text(
                      'New',
                      style: AppFonts.entryBodyText.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _navigateToRandom(context),
                    child: Text(
                      'Random',
                      style: AppFonts.entryBodyText.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _navigateToPopular(context),
                    child: Text(
                      'Popular',
                      style: AppFonts.entryBodyText.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Topic list
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildTopicItems(context),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar with four icons
      bottomNavigationBar: Container(
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shuffle),
              color: AppColors.primary,
              onPressed: () => _navigateToRandom(context),
            ),
            IconButton(
              icon: const Icon(Icons.message),
              color: AppColors.primary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DmPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: AppColors.primary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTopicItems(BuildContext context) => [
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
  ];

  Widget _buildTopicItem(BuildContext context, String title, String count, {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () => _navigateToEntryDetail(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFF6F5FA) : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppFonts.entryBodyText.copyWith(color: const Color(0xFF010120)),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(
                count,
                textAlign: TextAlign.right,
                style: AppFonts.entryBodyText.copyWith(color: const Color(0xFFCDCDCD)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
