import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tatli_sozluk/models/message_model.dart';
import 'package:tatli_sozluk/services/message_service.dart';

class DmPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  
  const DmPage({
    super.key, 
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<DmPage> createState() => _DmPageState();
}

class _DmPageState extends State<DmPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
    // Mark messages as read
    if (currentUserId != null) {
      _messageService.markMessagesAsRead(currentUserId!, widget.receiverId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _messageService.sendMessage(
        content: _messageController.text.trim(),
        senderId: currentUserId!,
        receiverId: widget.receiverId,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          Text(widget.receiverName, style: AppFonts.usernameText),
          const Spacer(),
          const Icon(Icons.card_giftcard),
          const SizedBox(width: 10),
          const Icon(Icons.mail_outline),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (currentUserId == null) {
      return const Center(child: Text("Please log in"));
    }
    
    return Expanded(
      child: StreamBuilder<List<Message>>(
        stream: _messageService.getMessages(currentUserId!, widget.receiverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No messages yet"));
          }
          
          final messages = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              final message = messages[index];
              final fromMe = message.senderId == currentUserId;
              
              return Column(
                crossAxisAlignment: fromMe 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fromMe ? Colors.grey[300] : AppColors.background,
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
                          _formatTimestamp(message.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.white),
          const SizedBox(width: 10),
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
          const SizedBox(width: 10),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}
