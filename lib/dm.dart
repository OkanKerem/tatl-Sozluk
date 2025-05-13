import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/providers/message_provider.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';

class DmPage extends StatefulWidget {
  const DmPage({super.key});

  @override
  State<DmPage> createState() => _DmPageState();
}

class _DmPageState extends State<DmPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _otherUserId;
  String? _otherUserName;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get route arguments if any
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _otherUserId = args['userId'] as String?;
      _otherUserName = args['username'] as String?;
      
      if (_otherUserId != null) {
        // Load messages when the page opens
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<MessageProvider>(context, listen: false).loadMessages(_otherUserId!);
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Send a message
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _otherUserId == null) {
      return;
    }

    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final success = await messageProvider.sendMessage(_otherUserId!, _messageController.text.trim());
    
    if (success) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildMessageList(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Text(_otherUserName ?? "Chat", style: AppFonts.usernameText),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show user info if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_otherUserId == null || messageProvider.messages.isEmpty) {
            return const Center(
              child: Text("No messages yet"),
            );
          }

          // Get current user ID
          final currentUserId = Provider.of<UserProvider>(context, listen: false).userId;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messageProvider.messages.length,
            reverse: true, // Show newest messages at the bottom
            itemBuilder: (context, index) {
              final message = messageProvider.messages[index];
              final fromMe = message.senderId == currentUserId;
              final bgColor = fromMe ? Colors.grey[300] : AppColors.primary.withOpacity(0.1);
              final align = fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

              return Column(
                crossAxisAlignment: align,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: AppFonts.entryBodyText,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: AppFonts.entryBodyText.copyWith(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Add attachment functionality
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
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

