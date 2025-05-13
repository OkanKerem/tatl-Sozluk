import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String entryId; // Reference to the parent entry
  final String text;
  final String author;
  final String userId;
  final DateTime createdAt;
  final List<String> likedBy;
  
  Comment({
    required this.id,
    required this.entryId,
    required this.text,
    required this.author,
    required this.userId,
    required this.createdAt,
    required this.likedBy,
  });
  
  // Create Comment from Firestore document
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      entryId: data['entryId'] ?? '',
      text: data['text'] ?? '',
      author: data['author'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
  
  // Convert Comment to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'text': text,
      'author': author,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
    };
  }
} 