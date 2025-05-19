import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/search_provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/entry_detail.dart';
import 'package:tatli_sozluk/models/entry_model.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

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
            onChanged: (query) {
              searchProvider.searchEntries(query);
            },
            decoration: InputDecoration(
              hintText: 'Search entries...',
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchProvider.hasSearched && searchProvider.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Results for "${searchProvider.searchQuery}" ',
                  style: AppFonts.entryBodyText.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            
            Expanded(
              child: searchProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchProvider.hasSearched && searchProvider.searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                "No results found for \"${searchProvider.searchQuery}\"",
                                style: AppFonts.entryBodyText.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchProvider.searchResults.length,
                          itemBuilder: (context, index) {
                            final entry = searchProvider.searchResults[index];
                            return _buildEntryCard(context, entry);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, Entry entry) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/entry_detail',
        arguments: entry.id,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: AppFonts.entryTitleText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.description,
              style: AppFonts.entryBodyText.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: Provider.of<UserProvider>(context, listen: false).getUserById(entry.author),
                  builder: (context, snapshot) {
                    final authorName = snapshot.data?['nickname'] ?? 'Unknown User';
                    return Text(
                      'by $authorName',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    );
                  },
                ),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text('${entry.likedBy.length}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
