import 'package:flutter/material.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';

class DmPage extends StatelessWidget {
  const DmPage({super.key});

  final List<Map<String, dynamic>> messages = const [
    {
      'fromMe': false,
      'text': "can you send me invite for that entry you mentioned?",
    },
    {'fromMe': true, 'text': "yes ofc. pls click on it and you’ll see."},
    {
      'fromMe': false,
      'text': "Invitation:(What should i do before gym?)",
      'invitation': true,
    },
    {
      'fromMe': false,
      'text':
      "that’s awesome. Also, I liked your entry. Therefore, i’ll give you 10 points as gift!",
      'gift': true,
    },
    {
      'fromMe': false,
      'text': "Sent gift : 10 points!",
      'gift': true,
      'green': true,
    },
    {'fromMe': true, 'text': "thank youu so much!"},
  ];

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
          Text("Cem", style: AppFonts.usernameText),
          const Spacer(),
          const Icon(Icons.card_giftcard),
          const SizedBox(width: 10),
          const Icon(Icons.mail_outline),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final fromMe = message['fromMe'] ?? false;
          final bgColor =
          message['green'] == true
              ? Colors.green[100]
              : fromMe
              ? Colors.grey[300]
              : AppColors.background;
          final align =
          fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

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
                child: Text(
                  message['text'],
                  style: AppFonts.entryBodyText.copyWith(
                    color:
                    message['green'] == true ? Colors.green : Colors.black,
                  ),
                ),
              ),
              if (message['gift'] == true || message['invitation'] == true)
                Icon(
                  message['gift'] == true
                      ? Icons.card_giftcard
                      : Icons.mail_outline,
                  color: AppColors.primary,
                ),
            ],
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
          const Icon(Icons.add, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.camera_alt, color: Colors.black),
        ],
      ),
    );
  }
}
