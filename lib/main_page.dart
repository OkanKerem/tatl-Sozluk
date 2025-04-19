import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 844,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF5EFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 61,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
            left: -1,
            top: 112,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
          ),
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
                  _buildNavItem(Icons.home, true),
                  _buildNavItem(Icons.search, false),
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

  Widget _buildFilterButton(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0xFF262626) : const Color(0xFFF6F5FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: AppFonts.entryBodyText.copyWith(
          color: isSelected ? const Color(0xFFF5EFFF) : const Color(0xFF646464),
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTopicItem(
    String title,
    String count, {
    bool isHighlighted = false,
  }) {
    return Container(
      width: 390,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF6F5FA) : Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 306,
            child: Text(
              title,
              style: AppFonts.entryBodyText.copyWith(
                color: const Color(0xFF010120),
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
