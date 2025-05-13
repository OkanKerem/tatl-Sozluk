import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:tatli_sozluk/models/comment_model.dart';

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;
  String _currentEntryId = '';
  
  // Getters
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String get currentEntryId => _currentEntryId;
  
  // Firestore ve Auth referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  // Koleksiyon adı
  final String _collectionName = 'comments';
  
  // Bir entry'nin yorumlarını yükle
  Future<void> loadComments(String entryId) async {
    _isLoading = true;
    _currentEntryId = entryId;
    notifyListeners();
    
    try {
      final commentsSnapshot = await _firestore
          .collection(_collectionName)
          .where('entryId', isEqualTo: entryId)
          .orderBy('createdAt', descending: true)
          .get();
      
      _comments = commentsSnapshot.docs
          .map((doc) => Comment.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading comments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Yeni yorum ekle
  Future<bool> addComment(String entryId, String text, String authorName) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final newComment = Comment(
          id: '', // Firestore otomatik oluşturacak
          entryId: entryId,
          text: text,
          author: authorName,
          userId: user.uid,
          createdAt: DateTime.now(),
          likedBy: [],
        );
        
        // Yorumu Firestore'a ekle
        final docRef = await _firestore.collection(_collectionName).add(newComment.toMap());
        
        // Oluşturulan yorumu yerel listeye ekle
        final createdComment = Comment(
          id: docRef.id,
          entryId: entryId,
          text: text,
          author: authorName,
          userId: user.uid,
          createdAt: DateTime.now(),
          likedBy: [],
        );
        
        _comments.insert(0, createdComment);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Yorum sil
  Future<bool> deleteComment(String commentId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestore.collection(_collectionName).doc(commentId).delete();
      
      // Yerel listeden kaldır
      _comments.removeWhere((comment) => comment.id == commentId);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Yoruma like ekle/kaldır
  Future<bool> toggleLike(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore'dan mevcut yorumu al
        final commentDoc = await _firestore.collection(_collectionName).doc(commentId).get();
        final comment = Comment.fromFirestore(commentDoc);
        
        // Kullanıcı zaten like etmiş mi kontrol et
        final List<String> updatedLikes = List.from(comment.likedBy);
        if (updatedLikes.contains(user.uid)) {
          // Like'ı kaldır
          updatedLikes.remove(user.uid);
        } else {
          // Like ekle
          updatedLikes.add(user.uid);
        }
        
        // Firestore'u güncelle
        await _firestore.collection(_collectionName).doc(commentId).update({
          'likedBy': updatedLikes,
        });
        
        // Yerel listeyi güncelle
        final commentIndex = _comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          final updated = Comment(
            id: _comments[commentIndex].id,
            entryId: _comments[commentIndex].entryId,
            text: _comments[commentIndex].text,
            author: _comments[commentIndex].author,
            userId: _comments[commentIndex].userId,
            createdAt: _comments[commentIndex].createdAt,
            likedBy: updatedLikes,
          );
          _comments[commentIndex] = updated;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling like on comment: $e');
      return false;
    }
  }
} 