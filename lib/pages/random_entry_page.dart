import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class RandomEntryPage extends StatefulWidget {
  const RandomEntryPage({super.key});

  @override
  State<RandomEntryPage> createState() => _RandomEntryPageState();
}

class _RandomEntryPageState extends State<RandomEntryPage> {
  bool isLoading = true;
  List<Entry> randomEntries = [];

  @override
  void initState() {
    super.initState();
    _loadRandomEntries();
  }

  Future<void> _loadRandomEntries() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      await entryProvider.loadAllEntries();
      
      if (mounted) {
        final allEntries = entryProvider.allEntries;
        if (allEntries.isEmpty) {
          setState(() {
            randomEntries = [];
            isLoading = false;
          });
          return;
        }
        
        // Shuffle the entries to get random ones
        final shuffled = List<Entry>.from(allEntries);
        final random = Random();
        
        // Fisher-Yates shuffle algorithm
        for (var i = shuffled.length - 1; i > 0; i--) {
          final j = random.nextInt(i + 1);
          final temp = shuffled[i];
          shuffled[i] = shuffled[j];
          shuffled[j] = temp;
        }
        
        setState(() {
          // Take up to 10 random entries
          randomEntries = shuffled.take(10).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading random entries: ${e.toString()}')),
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
          'Random Entries',
          style: AppFonts.entryTitleText.copyWith(fontSize: 24, color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadRandomEntries,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "discover random entries",
                style: AppFonts.entryBodyText.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : randomEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No entries found',
                            style: AppFonts.entryBodyText,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRandomEntries,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: randomEntries.length,
                            itemBuilder: (context, index) {
                              final entry = randomEntries[index];
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
