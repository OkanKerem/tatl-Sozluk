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
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında random entry'yi yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntryProvider>(context, listen: false).getRandomEntry();
    });
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
          'Random Entry',
          style: AppFonts.entryTitleText.copyWith(fontSize: 24, color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              Provider.of<EntryProvider>(context, listen: false).getRandomEntry();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<EntryProvider>(
          builder: (context, entryProvider, child) {
            if (entryProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final randomEntry = entryProvider.randomEntry;
            if (randomEntry == null) {
              return const Center(
                child: Text('No entries found'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    randomEntry.title,
                    style: AppFonts.entryTitleText.copyWith(
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          randomEntry.description,
                          style: AppFonts.entryBodyText.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${randomEntry.likedBy.length}',
                                  style: AppFonts.entryBodyText.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              randomEntry.author,
                              style: AppFonts.usernameText.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
