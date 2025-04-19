import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/fonts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 844,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF5EFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          // Search Bar and Title
          Positioned(
            left: 16,
            top: 29,
            child: Container(
              width: 331,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: const Icon(Icons.search, color: Color(0xFF0B0B0B)),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Search',
                          style: AppFonts.entryTitleText.copyWith(
                            color: const Color(0xFF0B0B0B),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 41,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE5E8E9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 18,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 293,
                                  child: Text(
                                    'Enter keywords',
                                    style: AppFonts.entryBodyText.copyWith(
                                      color: const Color(0xFF90A4AE),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: const Icon(Icons.mic, size: 18, color: Color(0xFF90A4AE)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Results List
          Positioned(
            left: 0,
            top: 120,
            right: 0,
            bottom: 80,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: _buildSearchResults(),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 41,
            top: 780,
            child: Container(
              width: 307,
              height: 64,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, false),
                  _buildNavItem(Icons.search, true),
                  _buildNavItem(Icons.add_circle_outline, false),
                  _buildNavItem(Icons.person_outline, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSearchResults() {
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

    return results.map((result) => _buildSearchResultItem(result['title']!, result['count']!)).toList();
  }

  Widget _buildSearchResultItem(String title, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppFonts.entryBodyText.copyWith(
                color: const Color(0xFF010120),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              count,
              textAlign: TextAlign.right,
              style: AppFonts.entryBodyText.copyWith(
                color: const Color(0xFFCDCDCD),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey,
        size: 24,
      ),
    );
  }
} 