import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:tatli_sozluk/models/entry_model.dart';
import 'package:tatli_sozluk/providers/user_provider.dart';

class EntryProvider extends ChangeNotifier {
  List<Entry> _userEntries = [];
  List<Entry> _allEntries = [];
  bool _isLoading = false;
  
  // Getters
  List<Entry> get userEntries => _userEntries;
  List<Entry> get allEntries => _allEntries;
  bool get isLoading => _isLoading;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Firestore ve Auth referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  // Koleksiyon adı
  final String _collectionName = 'posts';
  
  // Kullanıcının kendi entry'lerini yükle
  Future<void> loadUserEntries() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('Loading entries for current user: ${user.uid}');
        
        // Get the user document to access their posts list
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          print('User document not found for current user');
          _userEntries = [];
          return;
        }
        
        final userData = userDoc.data()!;
        final userPosts = List<String>.from(userData['posts'] ?? []);
        
        if (userPosts.isEmpty) {
          print('Current user has no posts');
          _userEntries = [];
          return;
        }
        
        print('Found ${userPosts.length} post IDs for current user');
        
        // Create a list to hold the entries
        List<Entry> entries = [];
        
        // Get entries by their IDs
        for (String postId in userPosts) {
          try {
            final postDoc = await _firestore.collection(_collectionName).doc(postId).get();
            if (postDoc.exists) {
              entries.add(Entry.fromFirestore(postDoc));
            }
          } catch (e) {
            print('Error loading post $postId: $e');
          }
        }
        
        // Sort entries by creation date (newest first)
        entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _userEntries = entries;
        print('Successfully loaded ${_userEntries.length} entries for current user');
      }
    } catch (e) {
      print('Error loading user entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Tüm entry'leri yükle
  Future<void> loadAllEntries() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final entriesSnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      
      _allEntries = entriesSnapshot.docs
          .map((doc) => Entry.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading all entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Yeni entry oluştur
  Future<bool> createEntry(String title, String description, UserProvider userProvider) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final newEntry = Entry(
          id: '', // Firestore otomatik oluşturacak
          title: title,
          description: description,
          author: userProvider.username,
          userId: user.uid,
          createdAt: DateTime.now(),
          likedBy: [],
          comments: [],
        );
        
        // Entry'i Firestore'a ekle
        final docRef = await _firestore.collection(_collectionName).add(newEntry.toMap());
        
        // Oluşturulan entry'i kullanıcının entry'lerine ekle
        final createdEntry = Entry(
          id: docRef.id,
          title: title,
          description: description,
          author: userProvider.username,
          userId: user.uid,
          createdAt: DateTime.now(),
          likedBy: [],
          comments: [],
        );
        
        _userEntries.insert(0, createdEntry);
        
        // Kullanıcının posts listesine entry ID'sini ekle
        userProvider.addPost(docRef.id);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating entry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Entry sil
  Future<bool> deleteEntry(String entryId, UserProvider userProvider) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestore.collection(_collectionName).doc(entryId).delete();
      
      // Yorumları da sil (varsa)
      final commentsQuery = await _firestore
          .collection('comments')
          .where('entryId', isEqualTo: entryId)
          .get();
          
      final batch = _firestore.batch();
      for (var doc in commentsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // User entries listesinden kaldır
      _userEntries.removeWhere((entry) => entry.id == entryId);
      _allEntries.removeWhere((entry) => entry.id == entryId);
      
      // Kullanıcının posts listesinden de kaldır
      userProvider.removePost(entryId);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Entry'ye like ekle/kaldır
  Future<bool> toggleLike(String entryId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore'dan mevcut entry'yi al
        final entryDoc = await _firestore.collection(_collectionName).doc(entryId).get();
        final entry = Entry.fromFirestore(entryDoc);
        
        // Kullanıcı zaten like etmiş mi kontrol et
        final List<String> updatedLikes = List.from(entry.likedBy);
        if (updatedLikes.contains(user.uid)) {
          // Like'ı kaldır
          updatedLikes.remove(user.uid);
        } else {
          // Like ekle
          updatedLikes.add(user.uid);
        }
        
        // Firestore'u güncelle
        await _firestore.collection(_collectionName).doc(entryId).update({
          'likedBy': updatedLikes,
        });
        
        // Yerel listeleri güncelle
        final userEntryIndex = _userEntries.indexWhere((e) => e.id == entryId);
        if (userEntryIndex != -1) {
          final updated = Entry(
            id: _userEntries[userEntryIndex].id,
            title: _userEntries[userEntryIndex].title,
            description: _userEntries[userEntryIndex].description,
            author: _userEntries[userEntryIndex].author,
            userId: _userEntries[userEntryIndex].userId,
            createdAt: _userEntries[userEntryIndex].createdAt,
            likedBy: updatedLikes,
            comments: _userEntries[userEntryIndex].comments,
          );
          _userEntries[userEntryIndex] = updated;
        }
        
        final allEntryIndex = _allEntries.indexWhere((e) => e.id == entryId);
        if (allEntryIndex != -1) {
          final updated = Entry(
            id: _allEntries[allEntryIndex].id,
            title: _allEntries[allEntryIndex].title,
            description: _allEntries[allEntryIndex].description,
            author: _allEntries[allEntryIndex].author,
            userId: _allEntries[allEntryIndex].userId,
            createdAt: _allEntries[allEntryIndex].createdAt,
            likedBy: updatedLikes,
            comments: _allEntries[allEntryIndex].comments,
          );
          _allEntries[allEntryIndex] = updated;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }
  
  // Get entry by ID
  Future<Entry?> getEntryById(String entryId) async {
    try {
      // Check if entry is already in local lists
      final localEntry = _allEntries.firstWhere(
        (entry) => entry.id == entryId,
        orElse: () => _userEntries.firstWhere(
          (entry) => entry.id == entryId,
          orElse: () => Entry(
            id: '',
            title: '',
            description: '',
            author: '',
            userId: '',
            createdAt: DateTime.now(),
            likedBy: [],
            comments: [],
          ),
        ),
      );
      
      if (localEntry.id.isNotEmpty) {
        return localEntry;
      }
      
      // Fetch from Firestore if not in local lists
      final entryDoc = await _firestore.collection(_collectionName).doc(entryId).get();
      if (entryDoc.exists) {
        return Entry.fromFirestore(entryDoc);
      }
      
      return null;
    } catch (e) {
      print('Error getting entry by ID: $e');
      return null;
    }
  }
  
  // Get entries by user ID
  Future<List<Entry>> getEntriesByUserId(String userId) async {
    try {
      print('Loading entries for user: $userId');
      
      // First, get the user document to access their posts list
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('User document not found for userId: $userId');
        return [];
      }
      
      final userData = userDoc.data()!;
      final userPosts = List<String>.from(userData['posts'] ?? []);
      
      if (userPosts.isEmpty) {
        print('User has no posts');
        return [];
      }
      
      print('Found ${userPosts.length} post IDs for user: $userId');
      
      // Create a list to hold the entries
      List<Entry> entries = [];
      
      // Get entries by their IDs
      for (String postId in userPosts) {
        try {
          final postDoc = await _firestore.collection(_collectionName).doc(postId).get();
          if (postDoc.exists) {
            entries.add(Entry.fromFirestore(postDoc));
          }
        } catch (e) {
          print('Error loading post $postId: $e');
        }
      }
      
      // Sort entries by creation date (newest first)
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('Successfully loaded ${entries.length} entries for user: $userId');
      return entries;
    } catch (e) {
      print('Error getting entries by user ID: $e');
      return [];
    }
  }
  
  // Update entry content
  Future<bool> updateEntry(String entryId, String newTitle, String newDescription) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if the current user is the author
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Get the entry to update
      final entry = await getEntryById(entryId);
      if (entry == null) return false;
      
      // Verify the current user is the author
      if (entry.userId != user.uid) {
        print('User is not authorized to edit this entry');
        return false;
      }
      
      // Update in Firestore
      await _firestore.collection(_collectionName).doc(entryId).update({
        'title': newTitle,
        'title_lowercase': newTitle.toLowerCase(),
        'description': newDescription,
      });
      
      // Update local entries
      final userEntryIndex = _userEntries.indexWhere((e) => e.id == entryId);
      if (userEntryIndex != -1) {
        final updated = Entry(
          id: entry.id,
          title: newTitle,
          description: newDescription,
          author: entry.author,
          userId: entry.userId,
          createdAt: entry.createdAt,
          likedBy: entry.likedBy,
          comments: entry.comments,
        );
        _userEntries[userEntryIndex] = updated;
      }
      
      final allEntryIndex = _allEntries.indexWhere((e) => e.id == entryId);
      if (allEntryIndex != -1) {
        final updated = Entry(
          id: entry.id,
          title: newTitle,
          description: newDescription,
          author: entry.author,
          userId: entry.userId,
          createdAt: entry.createdAt,
          likedBy: entry.likedBy,
          comments: entry.comments,
        );
        _allEntries[allEntryIndex] = updated;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating entry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 