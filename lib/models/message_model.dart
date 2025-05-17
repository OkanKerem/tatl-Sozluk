import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final bool isRead;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isRead,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  // Convert Firestore data to Message object
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      content: data['content'] ?? '',
      isRead: data['isRead'] ?? false,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert Message object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isRead': isRead,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
    };
  }
} 