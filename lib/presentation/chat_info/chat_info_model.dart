import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:takutore/domain/room.dart';
import 'package:takutore/domain/user.dart';

class ChatInfoModel extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final Room room;
  final User user;
  bool isLoading = false;
  bool isBlocked = false;

  ChatInfoModel({@required this.room, @required this.user});

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future checkBlockedUser() async {
    final currentUser = _auth.currentUser;
    final document = _store.collection('users').doc(currentUser.uid);
    final doc = await document.get();

    this.isBlocked = doc.data()['blockedUserID'].contains(this.user.uid);
    notifyListeners();
  }

  Future addBlock() async {
    final currentUser = _auth.currentUser;
    final document = _store.collection('users').doc(currentUser.uid);
    await document.update(
      {
        'blockedUserID': FieldValue.arrayUnion([this.user.uid]),
      },
    );
  }

  Future removeBlock() async {
    final currentUser = _auth.currentUser;
    final document = _store.collection('users').doc(currentUser.uid);
    await document.update(
      {
        'blockedUserID': FieldValue.arrayRemove([this.user.uid]),
      },
    );
  }

  Future removeTalk() async {
    final user = _auth.currentUser;
    final collection = _store
        .collection('users')
        .doc(user.uid)
        .collection('rooms')
        .doc(room.documentId)
        .collection('messages');

    final docs = await collection.get();

    if (docs.docs.isEmpty) return;

    await Future.forEach(
      docs.docs,
      (doc) async {
        final document = collection.doc(doc.documentID);
        await document.delete();
      },
    );
  }
}
