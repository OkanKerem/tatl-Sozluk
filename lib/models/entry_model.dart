import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final String title;
  final String description;
  final String author;
  final String userId;
  final DateTime createdAt;
  final List<String> likedBy;
  // Comments will be in a separate collection with reference to this entry
  
  Entry({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.userId,
    required this.createdAt,
    required this.likedBy,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
  
  // Convert Entry to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
    };
  }
} 