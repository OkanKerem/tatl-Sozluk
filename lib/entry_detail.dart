import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class EntryDetailPage extends StatelessWidget {
  const EntryDetailPage({super.key});

  final List<Map<String, String>> entries = const [
    {
      'text':
          "harika bir futbolcu, bizim çocukların göz bebeği.\ngeleceğin her şeyi.",
      'author': "Yiğit Zorer",
    },
    {
      'text':
          "tecrübeye aç, madrid için erken.\nAma gelecek için geç kalınmış bi futbolcu.",
      'author': "Ali Şencan",
    },
    {'text': "fenerbahçeden ayrılmamalıydı.", 'author': "Cem Sümer"},
  ];

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from the previous page
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final title = args['title'] as String;
    final content = args['content'] as String;
    final count = args['count'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, title),
            const SizedBox(height: 10),
            _buildPaginationInfo(),
            const SizedBox(height: 10),
            _buildEntryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppFonts.entryTitleText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildPaginationInfo() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("<"),
        SizedBox(width: 10),
        Text("1/35"),
        SizedBox(width: 10),
        Text(">"),
      ],
    );
  }

  Widget _buildEntryList() {
    return Expanded(
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            color: AppColors.primary.withOpacity(0.1),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry['text']!, style: AppFonts.entryBodyText),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite_border),
                          SizedBox(width: 10),
                          Icon(Icons.comment),
                        ],
                      ),
                      Row(
                        children: [
                          Text(entry['author']!, style: AppFonts.usernameText),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
