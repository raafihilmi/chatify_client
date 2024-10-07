import 'dart:developer';

import 'package:chatify_client/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get all user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // get all user stream except blocked users
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection("Users")
        .doc(currentUser!.uid)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap(
      (snapshot) async {
        final blockedUser = snapshot.docs.map((doc) => doc.id).toList();
        final usersSnapshot = await _firestore.collection("Users").get();

        final result = usersSnapshot.docs
            .where((doc) =>
                doc.data()["email"] != currentUser.email &&
                !blockedUser.contains(doc.id))
            .map((doc) => doc.data())
            .toList();
        log("result : $result", name: "FAAAK");

        return result;
      },
    );
  }

  // send messages
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    // construct chat room ID for the two users
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");
    log(chatRoomID, name: "check bro");

    return _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // report user
  Future<void> reportUser(String messageId, userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  // block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({
      'blockedAt': FieldValue.serverTimestamp(),
      'blocked': true
    });
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .delete();
  }

  // get blocked user
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    final currentUser = _auth.currentUser;
    log(userId, name: 'uid: ');

    return _firestore
        .collection("Users")
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap(
          (snapshot) async {
        // Ambil daftar ID pengguna yang diblokir
        final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
        log(blockedUserIds.toString(), name: "Blocked User IDs:");

        // Ambil dokumen pengguna yang diblokir berdasarkan ID-nya
        final userDocs = await Future.wait(
          blockedUserIds.map(
                (id) => _firestore.collection("Users").doc(id).get(),
          ),
        );

        // Log ID dokumen pengguna
        final userIds = userDocs.map((doc) => doc.id).toList();
        log(userIds.toString(), name: "User Document IDs:");

        // Konversi setiap snapshot dokumen menjadi map, dengan penanganan data null
        return userDocs.map((doc) {
          if (doc.exists && doc.data() != null) {
            // Kembalikan data sebagai Map<String, dynamic>
            return Map<String, dynamic>.from(doc.data()!);
          } else {
            log('Document with ID ${doc.id} has no data', name: 'Null Document:');
            return <String, dynamic>{}; // Kembalikan map kosong jika dokumen tidak ada data
          }
        }).toList();
      },
    );
  }
}
