import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tatli_sozluk/models/message_model.dart';
import 'package:rxdart/rxdart.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String messagesCollection = 'messages';

  // Create new message
  Future<void> sendMessage({
    required String content,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      // Save message
      await _firestore.collection(messagesCollection).add({
        'content': content,
        'isRead': false,
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': Timestamp.now(),
      });
      
      // Update or create conversation
      await _updateConversation(
        senderId: senderId,
        receiverId: receiverId,
        lastMessage: content,
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  // Update conversation information
  Future<void> _updateConversation({
    required String senderId,
    required String receiverId,
    required String lastMessage,
  }) async {
    final timestamp = Timestamp.now();
    final participants = [senderId, receiverId];
    participants.sort(); // Sort for consistent ID creation
    
    final conversationId = '${participants[0]}_${participants[1]}';
    
    try {
      await _firestore.collection('conversations').doc(conversationId).set({
        'participants': participants,
        'lastMessage': lastMessage,
        'lastMessageTime': timestamp,
        'lastMessageSenderId': senderId,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating conversation: $e');
      rethrow;
    }
  }

  // Get messages between two users
  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    // Query for sent messages
    Query sentQuery = _firestore
        .collection(messagesCollection)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: otherUserId)
        .orderBy('timestamp', descending: true);
    
    // Query for received messages
    Query receivedQuery = _firestore
        .collection(messagesCollection)
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);
    
    // Create a single stream combining all messages
    return Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) async {
          // Run both queries
          QuerySnapshot sentSnapshot = await sentQuery.get();
          QuerySnapshot receivedSnapshot = await receivedQuery.get();
          
          // Combine results
          List<Message> messages = [
            ...sentSnapshot.docs.map((doc) => Message.fromFirestore(doc)),
            ...receivedSnapshot.docs.map((doc) => Message.fromFirestore(doc)),
          ];
          
          // Sort messages by time
          messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          return messages;
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(messagesCollection)
          .where('senderId', isEqualTo: otherUserId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get unread message count for a user
  Stream<int> getUnreadMessageCount(String userId) {
    return _firestore
        .collection(messagesCollection)
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get unread message count from a specific user
  Stream<int> getUnreadMessagesFromUser(String currentUserId, String otherUserId) {
    return _firestore
        .collection(messagesCollection)
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 