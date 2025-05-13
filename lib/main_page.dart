import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/search_page.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/profile_part.dart';
import 'package:tatli_sozluk/entry_detail.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _sortByNewest = true; // Default sorting - newest first
  
  @override
  void initState() {
    super.initState();
    // Load entries when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntryProvider>(context, listen: false).loadAllEntries();
    });
  }

  void _navigateToDetail(BuildContext context, Entry entry) {
    Navigator.pushNamed(
      context,
      '/entry_detail',
      arguments: entry.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryProvider>(
      builder: (context, entryProvider, child) {
        // Sort entries based on selected filter
        final entries = List<Entry>.from(entryProvider.allEntries);
        if (_sortByNewest) {
          // Already sorted by newest in the provider, nothing to do
        } else {
          // Sort by like count (most liked first)
          entries.sort((a, b) => b.likedBy.length.compareTo(a.likedBy.length));
        }
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF5EFFF),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Top filter buttons: Newest, Most Liked
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _sortByNewest = true;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            _sortByNewest ? AppColors.primary : Colors.transparent,
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Text(
                          'Newest',
                          style: AppFonts.entryBodyText.copyWith(
                            color: _sortByNewest ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _sortByNewest = false;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            !_sortByNewest ? AppColors.primary : Colors.transparent,
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Text(
                          'Most Liked',
                          style: AppFonts.entryBodyText.copyWith(
                            color: !_sortByNewest ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Entry list
                Expanded(
                  child: entryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : entries.isEmpty
                          ? Center(
                              child: Text(
                                'No entries found',
                                style: AppFonts.entryBodyText,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return _buildEntryItem(context, entry);
                              },
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
                  icon: const Icon(Icons.refresh),
                  color: AppColors.primary,
                  onPressed: () {
                    // Refresh entries
                    Provider.of<EntryProvider>(context, listen: false).loadAllEntries();
                  },
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
      },
    );
  }

  Widget _buildEntryItem(BuildContext context, Entry entry) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, entry),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              entry.title,
              style: AppFonts.entryTitleText.copyWith(
                color: const Color(0xFF010120),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Description (preview)
            Text(
              entry.description.length > 100 
                  ? '${entry.description.substring(0, 100)}...'
                  : entry.description,
              style: AppFonts.entryBodyText.copyWith(
                color: const Color(0xFF010120),
              ),
            ),
            const SizedBox(height: 8),
            // Author and likes info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to author's profile
                    Navigator.pushNamed(
                      context,
                      '/user_profile',
                      arguments: entry.userId,
                    );
                  },
                  child: Text(
                    'by ${entry.author}',
                    style: AppFonts.entryBodyText.copyWith(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: entry.likedBy.isNotEmpty ? Colors.red : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.likedBy.length}',
                      style: AppFonts.entryBodyText.copyWith(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
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
