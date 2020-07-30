import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/room.dart';
import 'package:takutore/domain/user.dart';

class ChatInfoModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final Room room;
  final User user;
  bool isLoading = false;

  ChatInfoModel({@required this.room, @required this.user});

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future removeTalk() async {
    final user = await _auth.currentUser();
    final collection = _store
        .collection('users')
        .document(user.uid)
        .collection('rooms')
        .document(room.documentId)
        .collection('messages');

    final docs = await collection.getDocuments();

    if (docs.documents.isEmpty) return;

    await Future.forEach(
      docs.documents,
      (doc) async {
        final document = collection.document(doc.documentID);
        await document.delete();
      },
    );
  }
}
