import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class PopularEntriesPage extends StatefulWidget {
  const PopularEntriesPage({super.key});

  @override
  State<PopularEntriesPage> createState() => _PopularEntriesPageState();
}

class _PopularEntriesPageState extends State<PopularEntriesPage> {
  bool isLoading = true;
  List<Entry> popularEntries = [];

  @override
  void initState() {
    super.initState();
    _loadPopularEntries();
  }

  Future<void> _loadPopularEntries() async {
    try {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      await entryProvider.loadAllEntries();
      
      if (mounted) {
        setState(() {
          // Get all entries and sort by like count
          popularEntries = List.from(entryProvider.allEntries);
          popularEntries.sort((a, b) => b.likedBy.length.compareTo(a.likedBy.length));
          // Take top 20 entries or all if less than 20
          popularEntries = popularEntries.take(20).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading popular entries: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToEntryDetail(Entry entry) {
    Navigator.pushNamed(
      context,
      '/entry_detail',
      arguments: entry.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Popular Entries',
          style: AppFonts.entryTitleText.copyWith(
            fontSize: 24,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "most liked entries recently",
                style: AppFonts.entryBodyText.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : popularEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No popular entries found',
                            style: AppFonts.entryBodyText,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadPopularEntries,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: popularEntries.length,
                            itemBuilder: (context, index) {
                              final entry = popularEntries[index];
                              return GestureDetector(
                                onTap: () => _navigateToEntryDetail(entry),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.title,
                                              style: AppFonts.entryBodyText.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'by ${entry.author}',
                                              style: AppFonts.entryBodyText.copyWith(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${entry.likedBy.length}',
                                            style: AppFonts.entryBodyText.copyWith(
                                              fontSize: 15,
                                              color: const Color(0xFFCDCDCD),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
