import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String selectedFilter = 'today';

  void _selectFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
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
                const SizedBox(height: 61),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _buildFilterButton('today', isSelected: selectedFilter == 'today'),
                          const SizedBox(width: 8),
                          _buildFilterButton('news', isSelected: selectedFilter == 'news'),
                          const SizedBox(width: 8),
                          _buildFilterButton('top', isSelected: selectedFilter == 'top'),
                          const SizedBox(width: 8),
                          _buildFilterButton('follows', isSelected: selectedFilter == 'follows'),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/popular');
                          },
                          child: Text(
                            'Popular',
                            style: AppFonts.entryBodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildTopicItem('who wants to be a millionaire', '125'),
                    _buildTopicItem('midnight at pera palas', '30'),
                    _buildTopicItem(
                      "tatlı sözlük's database of people to chat",
                      '199',
                    ),
                    _buildTopicItem(
                      'simple things that make you happy',
                      '280',
                      isHighlighted: true,
                    ),
                    _buildTopicItem('sapiosexual', '57'),
                    _buildTopicItem(
                      "driver's license fee Rising to 10,000 Lira",
                      '23',
                    ),
                    _buildTopicItem('arda güler', '12'),
                    _buildTopicItem(
                      'january 2023 civil servant salary increase',
                      '10',
                    ),
                    _buildTopicItem('sitting alone in a café', '5'),
                    _buildTopicItem('a mother monkey bathing her baby', '7'),
                    _buildTopicItem(
                      'december 11 serbian foreign affairs statement',
                      '20',
                    ),
                    _buildTopicItem('post a cat picture for the night', '32'),
                    _buildTopicItem('seagull 1963', '55'),
                    _buildTopicItem('judgment (tv series)', '221'),
                  ],
                ),
                const SizedBox(height: 80), // Bottom padding for navigation bar
              ],
            ),
          ),
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
                  _buildNavItem(Icons.home, true, () {}),
                  _buildNavItem(Icons.search, false, () {
                    Navigator.pushNamed(context, '/search');
                  }),
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

  Widget _buildFilterButton(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _selectFilter(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF262626) : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppFonts.entryBodyText.copyWith(
            color: isSelected ? AppColors.background : const Color(0xFF646464),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicItem(
    String title,
    String count, {
    bool isHighlighted = false,
  }) {
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
          color: isHighlighted ? AppColors.background : Colors.transparent,
          border: isHighlighted 
            ? Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              )
            : null,
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
