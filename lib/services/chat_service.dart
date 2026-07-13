import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopverse/models/chat_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  
  io.Socket? _socket;

  // Local fallback state for demo/mock mode
  static final List<ChatMessage> _mockMessages = [
    ChatMessage(
      id: 'm1',
      senderId: 'admin',
      receiverId: 'demo_user',
      text: 'Hello! Welcome to ShopVerse Support. How can we help you today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];
  
  static final StreamController<List<ChatMessage>> _mockMessagesController = 
      StreamController<List<ChatMessage>>.broadcast()..add(_mockMessages);

  void connectSocket(String userId) {
    try {
      // Connect to Socket.IO backend gateway
      _socket = io.io('https://chat-gateway.shopverse.com', io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setQuery({'userId': userId})
        .build());
      
      _socket?.connect();
      
      _socket?.onConnect((_) {
        debugPrint('Socket.IO connection established for support chat');
      });
    } catch (e) {
      debugPrint('Socket.IO setup error: $e');
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
  }

  Stream<List<ChatMessage>> getMessages(String userId, String adminId) {
    if (!_isFirebaseReady) {
      return _mockMessagesController.stream.map((messages) {
        final chatId = getChatId(userId, adminId);
        return messages.where((msg) {
          final msgChatId = getChatId(msg.senderId, msg.receiverId);
          return msgChatId == chatId;
        }).toList();
      });
    }

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
    try {
      if (_socket != null && _socket!.connected) {
        _socket!.emit('send_message', message.toJson());
        debugPrint('Message emitted to WebSocket server: ${message.text}');
      }
    } catch (e) {
      debugPrint('Socket.IO emit failed: $e');
    }

    if (!_isFirebaseReady) {
      _mockMessages.insert(0, message);
      _mockMessagesController.add(_mockMessages);
      
      // Auto-respond for support chat in mock mode
      Future.delayed(const Duration(seconds: 1), () {
        final replyText = _getMockAdminReply(message.text);
        final reply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: message.receiverId == 'demo_user' ? 'admin' : message.receiverId,
          receiverId: message.senderId,
          text: replyText,
          timestamp: DateTime.now(),
        );
        _mockMessages.insert(0, reply);
        _mockMessagesController.add(_mockMessages);
      });
      return;
    }

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

  String _getMockAdminReply(String query) {
    final msg = query.toLowerCase();
    if (msg.contains('order') || msg.contains('track')) {
      return "I can help you track your order. Please share your order ID (e.g., ORD-8821).";
    } else if (msg.contains('refund') || msg.contains('return')) {
      return "To start a return or refund, go to 'Orders', select the item, and tap 'Return'.";
    } else if (msg.contains('coupon') || msg.contains('discount')) {
      return "Active codes can be applied at checkout. Try 'WELCOME50' for a flat discount!";
    } else if (msg.contains('hi') || msg.contains('hello')) {
      return "Hello! I am your ShopVerse AI Support agent. How can I help you today?";
    } else {
      return "Thanks for reaching out! A human agent has been alerted and will respond shortly.";
    }
  }

  String getChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';
  }

  Stream<List<Map<String, dynamic>>> getAdminChatList() {
    if (!_isFirebaseReady) {
      return _mockMessagesController.stream.map((messages) {
        final Map<String, ChatMessage> latestChats = {};
        for (var msg in messages) {
          final chatId = getChatId(msg.senderId, msg.receiverId);
          if (!latestChats.containsKey(chatId) || msg.timestamp.isAfter(latestChats[chatId]!.timestamp)) {
            latestChats[chatId] = msg;
          }
        }
        return latestChats.values.map((msg) {
          return {
            'lastMessage': msg.text,
            'lastTimestamp': msg.timestamp.toIso8601String(),
            'participants': [msg.senderId, msg.receiverId],
          };
        }).toList();
      });
    }

    return _firestore
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
