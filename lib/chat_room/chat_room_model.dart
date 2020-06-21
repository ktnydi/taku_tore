import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../message.dart';
import '../room.dart';
import '../user.dart';

class ChatRoomModel extends ChangeNotifier {
  List<Message> messages = [];
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

  Future fetchMessages({Room room}) async {
    final user = await FirebaseAuth.instance.currentUser();
    final collection = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('rooms')
        .document(room.documentId)
        .collection('messages')
        .orderBy('createdAt', descending: false);

    final messages = collection.snapshots().asyncMap((snapshot) {
      return Future.wait(
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

    messages.listen((messages) {
      this.messages = messages;
      notifyListeners();
    });
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
}
