import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/fonts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E8E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Ara...',
              hintStyle: AppFonts.entryBodyText.copyWith(
                color: const Color(0xFF90A4AE),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF90A4AE)),
              suffixIcon: const Icon(Icons.mic, color: Color(0xFF90A4AE)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5EFFF),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: _buildSearchResults(),
        ),
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
} 