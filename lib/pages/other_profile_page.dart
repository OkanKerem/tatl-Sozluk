import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class OtherProfilePage extends StatefulWidget {
  final String userId;
  
  const OtherProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  // Avatar listesi - sign_in.dart ile aynı olmalı
  final List<String> _avatarAssets = [
    'assets/Images/girlAvatar.png',
    'assets/Images/boyAvatar.png',
    'assets/Images/girlAvatar.png',
    'assets/Images/boyAvatar.png',
    'assets/Images/boyAvatar.png'
  ];
  
  String displayUsername = '';
  int profilePictureIndex = 1;
  List<String> followers = [];
  List<String> following = [];
  List<Entry> userEntries = [];
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    
    // Widget mount edildiğinde kullanıcı verilerini ve entry'leri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }
  
  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
    });
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    try {
      // Check if this is current user's profile
      if (widget.userId == userProvider.userId) {
        // If viewing our own profile, redirect to profile page
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
        return;
      }
      
      // Load user details
      final otherUserData = await userProvider.getUserById(widget.userId);
      
      // Load user entries
      final otherUserEntries = await entryProvider.getEntriesByUserId(widget.userId);
      
      if (mounted && otherUserData != null) {
        // Check if current user is following this user
        final currentUserFollowing = userProvider.following;
        final isCurrentlyFollowing = currentUserFollowing.contains(widget.userId);
        
        setState(() {
          displayUsername = otherUserData['nickname'] ?? 'Unknown User';
          profilePictureIndex = otherUserData['profilePicture'] ?? 1;
          followers = List<String>.from(otherUserData['followers'] ?? []);
          following = List<String>.from(otherUserData['following'] ?? []);
          userEntries = otherUserEntries;
          isFollowing = isCurrentlyFollowing;
          isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleFollow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });
    
    bool success;
    if (isFollowing) {
      // Unfollow user
      success = await userProvider.unfollowUser(widget.userId);
    } else {
      // Follow user
      success = await userProvider.followUser(widget.userId);
    }
    
    if (success && mounted) {
      setState(() {
        isFollowing = !isFollowing;
        
        // Update followers count locally
        if (isFollowing) {
          if (!followers.contains(userProvider.userId)) {
            followers.add(userProvider.userId);
          }
        } else {
          followers.remove(userProvider.userId);
        }
      });
    }
    
    setState(() {
      isLoading = false;
    });
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: AppFonts.usernameText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFFDF1F1),
                  backgroundImage: AssetImage(
                      _avatarAssets[profilePictureIndex - 1]),
                ),
                const SizedBox(height: 16),
                Text(displayUsername, style: AppFonts.usernameText),
                const SizedBox(height: 16),
                
                // Follow/Unfollow button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey : AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _toggleFollow,
                  child: Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      fontFamily: 'Itim',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('${followers.length}', style: AppFonts.countText),
                        Text('Followers', style: AppFonts.entryBodyText),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text('${following.length}', style: AppFonts.countText),
                        Text('Following', style: AppFonts.entryBodyText),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Entries (${userEntries.length})', style: AppFonts.entriesLabelText),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: userEntries.isEmpty
                      ? Center(
                          child: Text(
                            'This user has not created any entries yet.',
                            textAlign: TextAlign.center,
                            style: AppFonts.entryBodyText,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: userEntries.length,
                          itemBuilder: (context, index) {
                            final entry = userEntries[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GestureDetector(
                                onTap: () => _navigateToEntryDetail(entry),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.title, style: AppFonts.entryTitleText),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry.description.length > 100
                                              ? '${entry.description.substring(0, 100)}...'
                                              : entry.description,
                                          style: AppFonts.entryBodyText
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: entry.likedBy.isNotEmpty ? Colors.red : Colors.grey,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${entry.likedBy.length}',
                                              style: AppFonts.entryBodyText.copyWith(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 