import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tatli_sozluk/dm.dart';
import 'package:tatli_sozluk/utils/colors.dart';
import 'package:tatli_sozluk/utils/fonts.dart';
import 'package:tatli_sozluk/services/message_service.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MessageService _messageService = MessageService();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Please login to view your messages'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<String>> (
        stream: _getUsersWithMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          final userIds = snapshot.data!;
          
          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              final otherUserId = userIds[index];
              
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final username = userData?['nickname'] ?? 'Unknown User';
                  
                  return StreamBuilder<int>(
                    stream: _messageService.getUnreadMessagesFromUser(
                      currentUserId!,
                      otherUserId,
                    ),
                    builder: (context, unreadSnapshot) {
                      final unreadCount = unreadSnapshot.data ?? 0;
                      
                      return FutureBuilder<DocumentSnapshot?>(
                        future: _getLastMessage(otherUserId),
                        builder: (context, lastMessageSnapshot) {
                          String lastMessageText = '';
                          Timestamp? lastMessageTime;
                          bool isFromMe = false;

                          if (lastMessageSnapshot.hasData && lastMessageSnapshot.data != null) {
                            final lastMessage = lastMessageSnapshot.data!.data() as Map<String, dynamic>?;
                            if (lastMessage != null) {
                              lastMessageText = lastMessage['content'] ?? '';
                              lastMessageTime = lastMessage['timestamp'] as Timestamp?;
                              isFromMe = lastMessage['senderId'] == currentUserId;
                            }
                          }
                          
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              username,
                              style: AppFonts.usernameText,
                            ),
                            subtitle: Text(
                              lastMessageText.isNotEmpty 
                                  ? '${isFromMe ? 'You: ' : ''}$lastMessageText${lastMessageTime != null ? ' · ${_formatTimestamp(lastMessageTime)}' : ''}'
                                  : 'No messages',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: unreadCount > 0
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DmPage(
                                    receiverId: otherUserId,
                                    receiverName: username,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<String>> _getUsersWithMessages() {
    // Kullanıcının mesajlaştığı diğer kullanıcıların ID'lerini getir
    return _firestore
      .collection('messages')
      .where('senderId', isEqualTo: currentUserId)
      .snapshots()
      .asyncMap((senderSnapshot) async {
        final senderDocs = senderSnapshot.docs;
        
        final receiverSnapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .get();
        
        final receiverDocs = receiverSnapshot.docs;
        
        // Mesajlaşılan kullanıcıların ID'lerini topla
        final Set<String> userIds = {};
        
        for (var doc in senderDocs) {
          userIds.add(doc['receiverId'] as String);
        }
        
        for (var doc in receiverDocs) {
          userIds.add(doc['senderId'] as String);
        }
        
        return userIds.toList();
      });
  }

  Future<DocumentSnapshot?> _getLastMessage(String otherUserId) async {
    // İki kullanıcı arasındaki en son mesajı bul
    final query1 = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: otherUserId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    final query2 = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    final docs1 = query1.docs;
    final docs2 = query2.docs;

    if (docs1.isEmpty && docs2.isEmpty) {
      return null;
    }

    if (docs1.isEmpty) {
      return docs2.first;
    }

    if (docs2.isEmpty) {
      return docs1.first;
    }

    final timestamp1 = docs1.first['timestamp'] as Timestamp;
    final timestamp2 = docs2.first['timestamp'] as Timestamp;

    return timestamp1.compareTo(timestamp2) > 0 ? docs1.first : docs2.first;
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
} 