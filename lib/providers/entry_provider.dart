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
        final entriesSnapshot = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();
        
        _userEntries = entriesSnapshot.docs
            .map((doc) => Entry.fromFirestore(doc))
            .toList();
        
        notifyListeners();
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
} 