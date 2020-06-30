import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/message.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatRoomModel extends ChangeNotifier {
  Future<List<Message>> messagesAsFuture;
  Stream<List<Message>> messagesAsStream;
  Room room;

  Future<User> fetchUserFromFirebase({@required String userId}) async {
    final userRef = Firestore.instance.collection('users').document(userId);
    final user = await userRef.get();
    return User(
      uid: user.documentID,
      displayName: user['displayName'],
      photoURL: user['photoURL'],
      isTeacher: user['isTeacher'],
      createdAt: user['createdAt'],
      about: user['about'],
      canDo: user['canDo'],
      recommend: user['recommend'],
    );
  }

  Future fetchMessagesAsStream({Room room}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(room.documentId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    final messages = collection.snapshots().asyncMap((snapshot) {
      final isUploading = snapshot.metadata.hasPendingWrites;
      if (isUploading) {
        return this.messagesAsFuture;
      }

      return this.messagesAsFuture = Future.wait(
        snapshot.documents.map(
          (doc) async {
            final fromUser =
                await fetchUserFromFirebase(userId: doc['fromUid']);
            final toUser = await fetchUserFromFirebase(userId: doc['toUid']);
            return Message(
              from: fromUser,
              to: toUser,
              content: doc['content'],
              createdAt: doc['createdAt'],
            );
          },
        ),
      );
    });

    this.messagesAsStream = messages;
    notifyListeners();
  }

  Future addMessage({String text}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(room.documentId)
        .collection('messages');
    final from = currentUser.uid;
    final to = this.room.student.uid == currentUser.uid
        ? this.room.teacher.uid
        : this.room.student.uid;
    await collection.add({
      'fromUid': from,
      'toUid': to,
      'content': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future addMessageWithTransition({String text}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final document = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(room.documentId)
        .collection('messages')
        .document();
    final from = currentUser.uid;
    final to = this.room.student.uid == currentUser.uid
        ? this.room.teacher.uid
        : this.room.student.uid;

    await Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        document,
        {
          'fromUid': from,
          'toUid': to,
          'content': text,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }
}
