import 'dart:developer';

import 'package:chatify_client/components/user_tile.dart';
import 'package:chatify_client/services/auth/auth_service.dart';
import 'package:chatify_client/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class BlockedUserPage extends StatelessWidget {
  BlockedUserPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  void _showUnblockBox(BuildContext context, String userId) {
    showDialog(context: context, builder: (context) =>
        AlertDialog(
          title: const Text("Unblock User"),
          content: const Text("Are you sure you want unblock this user?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(onPressed: () {
              Navigator.pop(context);
              chatService.unblockUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User unblocked")));
            }, child: const Text("Unblock")),
          ],
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    String userId = authService.getCurrentUser()!.uid;
    log(userId);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockedUsersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log("Error: ${snapshot.error} , ${snapshot.data}");
            return Center(
              child: Text("Error: ${snapshot.error} ${snapshot.data}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final blockedUser = snapshot.data ?? [];

          if (blockedUser.isEmpty) {
            return const Center(
              child: Text("No available data"),
            );
          }
          return ListView.builder(
            itemCount: blockedUser.length,
            itemBuilder: (context, index) {
              final user = blockedUser[index];
              return UserTile(text: user["email"],
                  onTap: () => _showUnblockBox(context, user['uid']));
            },
          );
        },
      ),
    );
  }
}
