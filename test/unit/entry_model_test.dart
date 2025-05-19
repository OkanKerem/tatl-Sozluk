import 'package:flutter_test/flutter_test.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

void main() {
  group('Entry Model Tests', () {
    final testDate = DateTime(2023, 1, 1);
    
    test('Entry should be created with correct properties', () {
      // Arrange
      final entry = Entry(
        id: 'test-entry-123',
        title: 'Test Entry',
        description: 'This is a test entry description',
        authorId: 'author-123',
        createdAt: testDate,
        updatedAt: testDate,
        likeCount: 5,
        commentCount: 3,
        likedBy: ['user1', 'user2'],
        tags: ['test', 'flutter'],
      );

      // Assert
      expect(entry.id, 'test-entry-123');
      expect(entry.title, 'Test Entry');
      expect(entry.description, 'This is a test entry description');
      expect(entry.authorId, 'author-123');
      expect(entry.createdAt, testDate);
      expect(entry.updatedAt, testDate);
      expect(entry.likeCount, 5);
      expect(entry.commentCount, 3);
      expect(entry.likedBy, ['user1', 'user2']);
      expect(entry.tags, ['test', 'flutter']);
    });

    test('Entry.fromJson should correctly parse JSON data', () {
      // Arrange
      final json = {
        'id': 'json-entry-123',
        'title': 'JSON Entry',
        'description': 'This is a JSON entry description',
        'authorId': 'author-456',
        'createdAt': testDate.millisecondsSinceEpoch,
        'updatedAt': testDate.millisecondsSinceEpoch,
        'likeCount': 10,
        'commentCount': 7,
        'likedBy': ['user3', 'user4', 'user5'],
        'tags': ['json', 'test', 'dart'],
      };

      // Act
      final entry = Entry.fromJson(json);

      // Assert
      expect(entry.id, 'json-entry-123');
      expect(entry.title, 'JSON Entry');
      expect(entry.description, 'This is a JSON entry description');
      expect(entry.authorId, 'author-456');
      expect(entry.createdAt.millisecondsSinceEpoch, testDate.millisecondsSinceEpoch);
      expect(entry.updatedAt.millisecondsSinceEpoch, testDate.millisecondsSinceEpoch);
      expect(entry.likeCount, 10);
      expect(entry.commentCount, 7);
      expect(entry.likedBy, ['user3', 'user4', 'user5']);
      expect(entry.tags, ['json', 'test', 'dart']);
    });

    test('toJson should return correct JSON representation', () {
      // Arrange
      final entry = Entry(
        id: 'test-entry-456',
        title: 'ToJSON Test',
        description: 'This is a toJSON test description',
        authorId: 'author-789',
        createdAt: testDate,
        updatedAt: testDate,
        likeCount: 15,
        commentCount: 12,
        likedBy: ['user6', 'user7'],
        tags: ['json', 'test'],
      );

      // Act
      final json = entry.toJson();

      // Assert
      expect(json['id'], 'test-entry-456');
      expect(json['title'], 'ToJSON Test');
      expect(json['description'], 'This is a toJSON test description');
      expect(json['authorId'], 'author-789');
      expect(json['createdAt'], testDate.millisecondsSinceEpoch);
      expect(json['updatedAt'], testDate.millisecondsSinceEpoch);
      expect(json['likeCount'], 15);
      expect(json['commentCount'], 12);
      expect(json['likedBy'], ['user6', 'user7']);
      expect(json['tags'], ['json', 'test']);
    });

    test('toggleLike should add userId if not liked', () {
      // Arrange
      final entry = Entry(
        id: 'like-test-123',
        title: 'Like Test',
        description: 'Testing like functionality',
        authorId: 'author-abc',
        createdAt: testDate,
        updatedAt: testDate,
        likeCount: 2,
        commentCount: 0,
        likedBy: ['user1', 'user2'],
        tags: [],
      );

      // Act
      final newEntry = entry.toggleLike('user3');

      // Assert
      expect(newEntry.likedBy.length, 3);
      expect(newEntry.likedBy.contains('user3'), true);
      expect(newEntry.likeCount, 3);
    });

    test('toggleLike should remove userId if already liked', () {
      // Arrange
      final entry = Entry(
        id: 'like-test-456',
        title: 'Unlike Test',
        description: 'Testing unlike functionality',
        authorId: 'author-def',
        createdAt: testDate,
        updatedAt: testDate,
        likeCount: 3,
        commentCount: 0,
        likedBy: ['user1', 'user2', 'user3'],
        tags: [],
      );

      // Act
      final newEntry = entry.toggleLike('user2');

      // Assert
      expect(newEntry.likedBy.length, 2);
      expect(newEntry.likedBy.contains('user2'), false);
      expect(newEntry.likeCount, 2);
    });
  });
} 