import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserProvider extends ChangeNotifier {
  String _username = '';
  int _profilePictureIndex = 1;
  List<String> _followers = [];
  List<String> _following = [];
  List<String> _posts = [];
  bool _isLoading = true;
  
  // Getters
  String get username => _username;
  int get profilePictureIndex => _profilePictureIndex;
  List<String> get followers => _followers;
  List<String> get following => _following;
  List<String> get posts => _posts;
  bool get isLoading => _isLoading;
  
  // Add userId getter
  String get userId => _auth.currentUser?.uid ?? '';
  
  // Firestore ve Auth referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  // Kullanıcı verilerini yükle
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          
          _username = userData['nickname'] ?? '';
          _profilePictureIndex = userData['profilePicture'] ?? 1;
          _followers = List<String>.from(userData['followers'] ?? []);
          _following = List<String>.from(userData['following'] ?? []);
          _posts = List<String>.from(userData['posts'] ?? []);
          
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Profil fotoğrafını güncelle
  Future<bool> updateProfilePicture(int pictureIndex) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'profilePicture': pictureIndex,
        });
        
        _profilePictureIndex = pictureIndex;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Kullanıcı adını güncelle
  Future<bool> updateUsername(String newUsername) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nickname': newUsername,
        });
        
        _username = newUsername;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating username: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Entry ekle (bu sadece yerel listede güncelleme yapar, gerçek entryler başka koleksiyonda olabilir)
  void addPost(String postId) {
    _posts.add(postId);
    
    // Firebase'de güncelleme
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).update({
        'posts': _posts,
      });
    }
    
    notifyListeners();
  }
  
  // Entry sil
  void removePost(String postId) {
    _posts.remove(postId);
    
    // Firebase'de güncelleme
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).update({
        'posts': _posts,
      });
    }
    
    notifyListeners();
  }
  
  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
    _username = '';
    _profilePictureIndex = 1;
    _followers = [];
    _following = [];
    _posts = [];
    notifyListeners();
  }
  
  // Add getUserById method
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }
  
  // Follow a user
  Future<bool> followUser(String targetUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      // Add targetUserId to current user's following list
      if (!_following.contains(targetUserId)) {
        _following.add(targetUserId);
        await _firestore.collection('users').doc(currentUser.uid).update({
          'following': _following,
        });
      }
      
      // Add current user's ID to target user's followers list
      final targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
      if (targetUserDoc.exists) {
        final targetUserData = targetUserDoc.data()!;
        final List<String> targetUserFollowers = List<String>.from(targetUserData['followers'] ?? []);
        
        if (!targetUserFollowers.contains(currentUser.uid)) {
          targetUserFollowers.add(currentUser.uid);
          await _firestore.collection('users').doc(targetUserId).update({
            'followers': targetUserFollowers,
          });
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }
  
  // Unfollow a user
  Future<bool> unfollowUser(String targetUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      // Remove targetUserId from current user's following list
      _following.remove(targetUserId);
      await _firestore.collection('users').doc(currentUser.uid).update({
        'following': _following,
      });
      
      // Remove current user's ID from target user's followers list
      final targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
      if (targetUserDoc.exists) {
        final targetUserData = targetUserDoc.data()!;
        final List<String> targetUserFollowers = List<String>.from(targetUserData['followers'] ?? []);
        
        targetUserFollowers.remove(currentUser.uid);
        await _firestore.collection('users').doc(targetUserId).update({
          'followers': targetUserFollowers,
        });
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }
} 