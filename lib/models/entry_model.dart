import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final String title;
  final String description;
  final String author;
  final String userId;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String> comments; // Comment ID'lerinin listesi
  
  Entry({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.userId,
    required this.createdAt,
    required this.likedBy,
    required this.comments,
  });
  
  // Create Entry from Firestore document
  factory Entry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Entry(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }
  
  // Convert Entry to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'title_lowercase': title.toLowerCase(),
      'description': description,
      'author': author,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'comments': comments,
    };
  }
} 