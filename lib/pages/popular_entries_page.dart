import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class PopularEntriesPage extends StatelessWidget {
  const PopularEntriesPage({Key? key}) : super(key: key);

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
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF0B0B0B)),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Popular Entries',
                        style: AppFonts.entryTitleText.copyWith(
                          color: const Color(0xFF0B0B0B),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildEntryItem(
                      'who wants to be a millionaire',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      '125',
                      context,
                    ),
                    _buildEntryItem(
                      'midnight at pera palas',
                      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                      '30',
                      context,
                    ),
                    _buildEntryItem(
                      'simple things that make you happy',
                      'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                      '280',
                      context,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(String title, String content, String count, BuildContext context, {bool isHighlighted = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/entry', arguments: {
          'title': title,
          'content': content,
          'count': count,
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.background : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.entryTitleText.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF010120),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: AppFonts.entryBodyText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                count,
                style: AppFonts.countText.copyWith(
                  color: const Color(0xFFCDCDCD),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

