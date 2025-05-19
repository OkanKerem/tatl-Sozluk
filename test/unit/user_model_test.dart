import 'package:flutter_test/flutter_test.dart';
import 'package:tatli_sozluk/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('User should be created with correct properties', () {
      // Arrange
      final user = User(
        uid: 'test-uid-123',
        username: 'testuser',
        email: 'test@example.com',
        photoURL: 'https://example.com/photo.jpg',
        bio: 'Test user bio',
        followersCount: 10,
        followingCount: 5,
        entryCount: 3,
      );

      // Assert
      expect(user.uid, 'test-uid-123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.photoURL, 'https://example.com/photo.jpg');
      expect(user.bio, 'Test user bio');
      expect(user.followersCount, 10);
      expect(user.followingCount, 5);
      expect(user.entryCount, 3);
    });

    test('User.fromJson should correctly parse JSON data', () {
      // Arrange
      final json = {
        'uid': 'json-uid-123',
        'username': 'jsonuser',
        'email': 'json@example.com',
        'photoURL': 'https://example.com/json.jpg',
        'bio': 'JSON user bio',
        'followersCount': 15,
        'followingCount': 7,
        'entryCount': 5,
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.uid, 'json-uid-123');
      expect(user.username, 'jsonuser');
      expect(user.email, 'json@example.com');
      expect(user.photoURL, 'https://example.com/json.jpg');
      expect(user.bio, 'JSON user bio');
      expect(user.followersCount, 15);
      expect(user.followingCount, 7);
      expect(user.entryCount, 5);
    });

    test('toJson should return correct JSON representation', () {
      // Arrange
      final user = User(
        uid: 'test-uid-456',
        username: 'jsontest',
        email: 'jsontest@example.com',
        photoURL: 'https://example.com/jsontest.jpg',
        bio: 'JSON test bio',
        followersCount: 20,
        followingCount: 10,
        entryCount: 8,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['uid'], 'test-uid-456');
      expect(json['username'], 'jsontest');
      expect(json['email'], 'jsontest@example.com');
      expect(json['photoURL'], 'https://example.com/jsontest.jpg');
      expect(json['bio'], 'JSON test bio');
      expect(json['followersCount'], 20);
      expect(json['followingCount'], 10);
      expect(json['entryCount'], 8);
    });

    test('copyWith should create a new instance with updated values', () {
      // Arrange
      final user = User(
        uid: 'original-uid',
        username: 'original',
        email: 'original@example.com',
        photoURL: 'https://example.com/original.jpg',
        bio: 'Original bio',
        followersCount: 5,
        followingCount: 3,
        entryCount: 2,
      );

      // Act
      final updatedUser = user.copyWith(
        username: 'updated',
        bio: 'Updated bio',
        followersCount: 10,
      );

      // Assert
      expect(updatedUser.uid, 'original-uid'); // Unchanged
      expect(updatedUser.username, 'updated'); // Changed
      expect(updatedUser.email, 'original@example.com'); // Unchanged
      expect(updatedUser.photoURL, 'https://example.com/original.jpg'); // Unchanged
      expect(updatedUser.bio, 'Updated bio'); // Changed
      expect(updatedUser.followersCount, 10); // Changed
      expect(updatedUser.followingCount, 3); // Unchanged
      expect(updatedUser.entryCount, 2); // Unchanged
    });
  });
} 