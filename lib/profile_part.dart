import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, displays current user's profile
  
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final List<String> _avatarAssets = [
    'assets/Images/boyAvatar.png',
    'assets/Images/girlAvatar.png',
    'assets/Images/pp1.png',
    'assets/Images/pp2.png',
    'assets/Images/pp3.png',
  ];
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool isOwnProfile = true;
  String displayUsername = '';
  int profilePictureIndex = 1;
  List<String> followers = [];
  List<String> following = [];
  List<Entry> userEntries = [];
  bool isLoading = true;

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
      if (widget.userId == null || widget.userId == userProvider.userId) {
        // Load current user profile
        isOwnProfile = true;
        await userProvider.loadUserData();
        await entryProvider.loadUserEntries();
        
        if (mounted) {
          setState(() {
            displayUsername = userProvider.username;
            profilePictureIndex = userProvider.profilePictureIndex;
            followers = userProvider.followers;
            following = userProvider.following;
            userEntries = entryProvider.userEntries;
            isLoading = false;
          });
        }
      } else {
        // Load another user's profile
        isOwnProfile = false;
        
        // Load user details
        final otherUserData = await userProvider.getUserById(widget.userId!);
        
        // Load other user entries
        final otherUserEntries = await entryProvider.getEntriesByUserId(widget.userId!);
        
        if (mounted && otherUserData != null) {
          setState(() {
            displayUsername = otherUserData['nickname'] ?? 'Unknown User';
            profilePictureIndex = otherUserData['profilePicture'] ?? 1;
            followers = List<String>.from(otherUserData['followers'] ?? []);
            following = List<String>.from(otherUserData['following'] ?? []);
            userEntries = otherUserEntries;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not load user profile')),
            );
            Navigator.pop(context);
          }
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
  
  void _navigateToEntryDetail(Entry entry) {
    Navigator.pushNamed(
      context,
      '/entry_detail',
      arguments: entry.id,
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Entry silme metodu - sadece kendi profili ise gösterilir
  void deleteEntry(String entryId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    // EntryProvider'ı kullanarak entry'i sil
    bool success = await entryProvider.deleteEntry(entryId, userProvider);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted successfully')),
      );
      // Güncel kullanıcı entry listesini yenile
      setState(() {
        userEntries.removeWhere((entry) => entry.id == entryId);
      });
    }
  }

  // Yeni entry ekleme metodu - sadece kendi profili ise gösterilir
  void showAddEntryDialog() {
    _titleController.clear();
    _descriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Entry', style: AppFonts.infoLabelText),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppFonts.entryBodyText),
          ),
          TextButton(
            onPressed: () async {
              if (_titleController.text.trim().isNotEmpty && 
                  _descriptionController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await addEntry();
              }
            },
            child: Text('Create', style: AppFonts.entryBodyText),
          ),
        ],
      ),
    );
  }
  
  // Entry ekleme işlemi
  Future<void> addEntry() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    // EntryProvider'ı kullanarak yeni entry oluştur
    bool success = await entryProvider.createEntry(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      userProvider
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New entry created successfully')),
      );
      // Kullanıcı entry listesini güncelle
      await entryProvider.loadUserEntries();
      setState(() {
        userEntries = entryProvider.userEntries;
      });
    }
  }

  // Show edit entry dialog
  void showEditEntryDialog(Entry entry) {
    _titleController.text = entry.title;
    _descriptionController.text = entry.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Entry', style: AppFonts.infoLabelText),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppFonts.entryBodyText),
          ),
          TextButton(
            onPressed: () async {
              if (_titleController.text.trim().isNotEmpty && 
                  _descriptionController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await updateEntry(entry.id);
              }
            },
            child: Text('Save', style: AppFonts.entryBodyText),
          ),
        ],
      ),
    );
  }
  
  // Update entry
  Future<void> updateEntry(String entryId) async {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    // Update the entry using EntryProvider
    bool success = await entryProvider.updateEntry(
      entryId,
      _titleController.text.trim(),
      _descriptionController.text.trim(),
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully')),
      );
      // Refresh user entry list
      await entryProvider.loadUserEntries();
      setState(() {
        userEntries = entryProvider.userEntries;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update entry')),
      );
    }
  }

  Widget _buildProfilePictureSelector() {
    return Column(
      children: [
        const Text('Select Profile Picture'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProfilePictureOption('assets/Images/botAvatar.png'),
            _buildProfilePictureOption('assets/Images/girlAvatar.png'),
            _buildProfilePictureOption('assets/Images/pp1.png'),
            _buildProfilePictureOption('assets/Images/pp2.png'),
            _buildProfilePictureOption('assets/Images/pp3.png'),
          ],
        ),
      ],
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
          onPressed: () async {
            // Reload user data before returning to main page
            await Provider.of<UserProvider>(context, listen: false).loadUserData();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/main_page');
            }
          },
        ),
        actions: isOwnProfile ? [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ] : null,
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
                const SizedBox(height: 8),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Entries (${userEntries.length})', style: AppFonts.entriesLabelText),
                      if (isOwnProfile) ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: showAddEntryDialog,
                        child: const Text(
                          'New Entry',
                          style: TextStyle(
                            fontFamily: 'Itim',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: userEntries.isEmpty
                      ? Center(
                          child: Text(
                            isOwnProfile 
                                ? 'No entries yet.\nCreate your first entry!'
                                : 'This user has not created any entries yet.',
                            textAlign: TextAlign.center,
                            style: AppFonts.entryBodyText,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: userEntries.length,
                          itemBuilder: (context, index) {
                            final entry = userEntries[index];
                            return _buildEntryItem(entry);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEntryItem(Entry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEntryDetail(entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                entry.title,
                style: AppFonts.entryTitleText,
              ),
              const SizedBox(height: 8),
              // Content preview
              Text(
                entry.description.length > 100
                    ? '${entry.description.substring(0, 100)}...'
                    : entry.description,
                style: AppFonts.entryBodyText,
              ),
              const SizedBox(height: 12),
              // Stats and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Likes and comments count
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text('${entry.likedBy.length}'),
                      const SizedBox(width: 8),
                      Icon(Icons.comment, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text('${entry.comments.length}'),
                    ],
                  ),
                  // Actions (edit, delete) - only for own entries
                  if (isOwnProfile)
                    Row(
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => showEditEntryDialog(entry),
                        ),
                        const SizedBox(width: 16),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Entry'),
                                content: const Text('Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              deleteEntry(entry.id);
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureOption(String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          profilePictureIndex = _avatarAssets.indexOf(assetPath) + 1;
        });
      },
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[200],
        backgroundImage: AssetImage(assetPath),
      ),
    );
  }
}
