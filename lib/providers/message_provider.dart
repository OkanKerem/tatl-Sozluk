import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:tatli_sozluk/models/message_model.dart';

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String _currentChatUserId = '';
  
  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String get currentChatUserId => _currentChatUserId;
  
  // Firestore ve Auth referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  // Koleksiyon adı
  final String _collectionName = 'messages';
  
  // Belirli bir kullanıcı ile olan mesajlaşmayı yükle
  Future<void> loadMessages(String otherUserId) async {
    _isLoading = true;
    _currentChatUserId = otherUserId;
    notifyListeners();
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // İki kullanıcı arasındaki mesajları yükle (gönderilen ve alınan)
        final messagesStream = _firestore
            .collection(_collectionName)
            .where('senderId', whereIn: [currentUser.uid, otherUserId])
            .where('receiverId', whereIn: [currentUser.uid, otherUserId])
            .orderBy('timestamp', descending: true)
            .snapshots();
        
        // Stream'i dinle
        messagesStream.listen((snapshot) {
          _messages = snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .where((message) => 
                  (message.senderId == currentUser.uid && message.receiverId == otherUserId) || 
                  (message.senderId == otherUserId && message.receiverId == currentUser.uid))
              .toList();
          
          // Okunmamış mesajları okundu olarak işaretle
          _markMessagesAsRead(otherUserId);
          
          _isLoading = false;
          notifyListeners();
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Mesajları okundu olarak işaretle
  Future<void> _markMessagesAsRead(String otherUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Karşıdan gelen ve okunmamış mesajları bul
        final unreadMessages = _messages.where((message) => 
            message.senderId == otherUserId && 
            message.receiverId == currentUser.uid && 
            !message.isRead).toList();
        
        // Batch işlemi ile hepsini güncelle
        final batch = _firestore.batch();
        for (var message in unreadMessages) {
          final messageRef = _firestore.collection(_collectionName).doc(message.id);
          batch.update(messageRef, {'isRead': true});
        }
        
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  // Yeni mesaj gönder
  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final newMessage = Message(
          id: '', // Firestore otomatik oluşturacak
          senderId: currentUser.uid,
          receiverId: receiverId,
          content: content,
          timestamp: DateTime.now(),
          isRead: false,
        );
        
        // Mesajı Firestore'a ekle
        await _firestore.collection(_collectionName).add(newMessage.toMap());
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }
  
  // Son mesajlaşmaları getir (her bir kullanıcı için en son mesaj)
  Future<Map<String, Message>> getLastMessages() async {
    Map<String, Message> lastMessages = {};
    _isLoading = true;
    notifyListeners();
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Gönderilen mesajlar
        final sentMessages = await _firestore
            .collection(_collectionName)
            .where('senderId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .get();
            
        // Alınan mesajlar
        final receivedMessages = await _firestore
            .collection(_collectionName)
            .where('receiverId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .get();
        
        // Tüm mesajları birleştir
        List<Message> allMessages = [
          ...sentMessages.docs.map((doc) => Message.fromFirestore(doc)),
          ...receivedMessages.docs.map((doc) => Message.fromFirestore(doc)),
        ];
        
        // En son mesajları bul (her kullanıcı için)
        allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        for (var message in allMessages) {
          String otherUserId = message.senderId == currentUser.uid 
              ? message.receiverId : message.senderId;
              
          if (!lastMessages.containsKey(otherUserId)) {
            lastMessages[otherUserId] = message;
          }
        }
      }
    } catch (e) {
      print('Error getting last messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return lastMessages;
  }
  
  // Okunmamış mesaj sayısını getir
  Future<int> getUnreadMessageCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final unreadMessages = await _firestore
            .collection(_collectionName)
            .where('receiverId', isEqualTo: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .get();
            
        return unreadMessages.docs.length;
      }
    } catch (e) {
      print('Error getting unread message count: $e');
    }
    
    return 0;
  }
} 