import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopverse/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String userId, String adminId) {
    String chatId = getChatId(userId, adminId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromJson(doc.data())).toList();
    });
  }

  Future<void> sendMessage(ChatMessage message) async {
    String chatId = getChatId(message.senderId, message.receiverId);
    
    // Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'lastTimestamp': message.timestamp.toIso8601String(),
      'participants': [message.senderId, message.receiverId],
    }, SetOptions(merge: true));
  }

  String getChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';
  }

  Stream<List<Map<String, dynamic>>> getAdminChatList() {
    return _firestore
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
