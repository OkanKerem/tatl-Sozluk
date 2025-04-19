import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, String>> _buildSearchResults() {
    final results = [
      {'title': 'who wants to be a millionaire', 'count': '125'},
      {'title': 'midnight at pera palas', 'count': '30'},
      {'title': 'tatlı sözlük\'s database of people to chat', 'count': '199'},
      {'title': 'simple things that make you happy', 'count': '280'},
      {'title': 'sapiosexual', 'count': '57'},
      {'title': 'driver\'s license fee Rising to 10,000 Lira', 'count': '23'},
      {'title': 'arda güler', 'count': '12'},
      {'title': 'january 2023 civil servant salary increase', 'count': '10'},
      {'title': 'sitting alone in a café', 'count': '5'},
      {'title': 'a mother monkey bathing her baby', 'count': '7'},
      {'title': 'december 11 serbian foreign affairs statement', 'count': '20'},
      {'title': 'post a cat picture for the night', 'count': '32'},
      {'title': 'seagull 1963', 'count': '55'},
      {'title': 'judgment (tv series)', 'count': '221'},
    ];

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 29),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        width: double.infinity,
                        height: 48,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/'),
                              child: const Icon(Icons.arrow_back, color: Color(0xFF0B0B0B)),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: Color(0xFF0B0B0B)),
                            const SizedBox(width: 16),
                            Text(
                              'Search',
                              style: AppFonts.entryTitleText.copyWith(
                                color: const Color(0xFF0B0B0B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Search Input
                      Container(
                        width: double.infinity,
                        height: 41,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter keywords',
                                  hintStyle: AppFonts.entryBodyText.copyWith(
                                    color: const Color(0xFF90A4AE),
                                    fontSize: 12,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: AppFonts.entryBodyText.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.mic,
                              size: 18,
                              color: Color(0xFF90A4AE),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Search Results
                Column(
                  children: _buildSearchResults().map((result) => _buildSearchResultItem(result['title']!, result['count']!)).toList(),
                ),
                const SizedBox(height: 80), // Bottom padding for navigation bar
              ],
            ),
          ),
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, false, () {
                    Navigator.pushReplacementNamed(context, '/');
                  }),
                  _buildNavItem(Icons.search, true, () {}),
                  _buildNavItem(Icons.person_outline, false, () {
                    Navigator.pushNamed(context, '/profile');
                  }),
                  _buildNavItem(Icons.chat_bubble_outline, false, () {
                    Navigator.pushNamed(context, '/dm');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(String title, String count) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/entry', arguments: {
          'title': title,
          'content': 'This is a sample entry content for $title. More entries will be added later.',
          'count': count,
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppFonts.entryBodyText.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF010120),
                ),
              ),
            ),
            Text(
              count,
              textAlign: TextAlign.right,
              style: AppFonts.countText.copyWith(
                color: const Color(0xFFCDCDCD),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
} 