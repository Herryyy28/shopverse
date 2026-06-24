import 'package:flutter/material.dart';
import 'package:shopverse/services/chat_service.dart';
import 'package:shopverse/screens/core/chat_screen.dart';
import 'package:shopverse/utils/app_colors.dart';
import 'package:intl/intl.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Support Chats', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getAdminChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text("No support requests yet", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['participants'] ?? []);
              // Assuming admin ID is known or we filter for the non-admin ID
              // For simplicity, let's say the other ID is the customer
              // In a real app, you'd fetch the user's name from Firestore
              final customerId = participants.firstWhere((id) => id != 'admin', orElse: () => 'Unknown');
              final lastMessage = chat['lastMessage'] ?? '';
              final lastTimestamp = DateTime.parse(chat['lastTimestamp'] ?? DateTime.now().toIso8601String());

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.brandRed.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.brandRed),
                  ),
                  title: Text(
                    'Customer $customerId', // Ideally, fetch the actual name
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    DateFormat('MMM d, HH:mm').format(lastTimestamp),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: customerId,
                          receiverName: 'Customer $customerId',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
