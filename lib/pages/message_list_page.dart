import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/providers/message_provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';
import 'package:tatli_sozluk/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  bool _isLoading = false;
  late Map<String, Message> _lastMessages;
  late Map<String, String> _usernames;
  
  @override
  void initState() {
    super.initState();
    _lastMessages = {};
    _usernames = {};
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get message provider
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    // Get last messages for each conversation
    _lastMessages = await messageProvider.getLastMessages();
    
    // Load usernames for each user ID
    await _loadUsernames();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadUsernames() async {
    final firestore = FirebaseFirestore.instance;
    for (var userId in _lastMessages.keys) {
      try {
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('nickname')) {
            _usernames[userId] = userData['nickname'];
          } else {
            _usernames[userId] = 'Unknown User';
          }
        } else {
          _usernames[userId] = 'Unknown User';
        }
      } catch (e) {
        print('Error loading username for $userId: $e');
        _usernames[userId] = 'Unknown User';
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppFonts.entryTitleText.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildConversationList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Show dialog to start a new conversation
          _showNewConversationDialog();
        },
      ),
    );
  }
  
  Widget _buildConversationList() {
    if (_lastMessages.isEmpty) {
      return const Center(
        child: Text('No conversations yet'),
      );
    }
    
    final currentUserId = Provider.of<UserProvider>(context, listen: false).userId;
    
    return ListView.builder(
      itemCount: _lastMessages.length,
      itemBuilder: (context, index) {
        final userId = _lastMessages.keys.elementAt(index);
        final message = _lastMessages[userId]!;
        final username = _usernames[userId] ?? 'Unknown User';
        
        // Determine if the message is from the current user
        final isFromMe = message.senderId == currentUserId;
        
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(username, style: AppFonts.usernameText),
          subtitle: Text(
            (isFromMe ? 'You: ' : '') + message.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.entryBodyText.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            _formatTime(message.timestamp),
            style: AppFonts.entryBodyText.copyWith(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          onTap: () {
            // Navigate to the DM page
            Navigator.pushNamed(
              context,
              '/dm',
              arguments: {
                'userId': userId,
                'username': username,
              },
            );
          },
        );
      },
    );
  }
  
  void _showNewConversationDialog() {
    final TextEditingController _usernameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start New Conversation', style: AppFonts.infoLabelText),
        content: TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppFonts.entryBodyText),
          ),
          TextButton(
            onPressed: () async {
              if (_usernameController.text.trim().isEmpty) {
                return;
              }
              
              Navigator.pop(context);
              
              // Search for the user by username
              await _searchUserAndNavigate(_usernameController.text.trim());
            },
            child: Text('Search', style: AppFonts.entryBodyText),
          ),
        ],
      ),
    );
  }
  
  Future<void> _searchUserAndNavigate(String username) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnapshot = await firestore
          .collection('users')
          .where('nickname', isEqualTo: username)
          .limit(1)
          .get();
      
      if (usersSnapshot.docs.isNotEmpty) {
        final userDoc = usersSnapshot.docs.first;
        final userId = userDoc.id;
        final username = userDoc.data()['nickname'] ?? 'Unknown User';
        
        // Navigate to the DM page
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/dm',
            arguments: {
              'userId': userId,
              'username': username,
            },
          );
        }
      } else {
        // User not found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      }
    } catch (e) {
      print('Error searching for user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error searching for user')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Format the timestamp
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (today == messageDate) {
      // Today - just show time
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (today.subtract(const Duration(days: 1)) == messageDate) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other days
      return '${time.day}/${time.month}/${time.year}';
    }
  }
} 