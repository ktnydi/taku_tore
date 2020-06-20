import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../user.dart';

class BookmarkModel extends ChangeNotifier {
  List<User> teachers = [];

  Future fetchBookmarks() async {
    final user = await FirebaseAuth.instance.currentUser();
    final collection = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('bookmarks');
    final docs = await collection.getDocuments();
    final teachers = Future.wait(
      docs.documents.map((doc) async {
        final teacherRef =
            Firestore.instance.collection('users').document(doc['teacherId']);
        final document = await teacherRef.get();
        return User(
          uid: document.documentID,
          displayName: document['displayName'],
          photoURL: document['photoURL'],
          isTeacher: document['isTeacher'],
          createdAt: document['createdAt'],
          about: document['about'],
          canDo: document['canDo'],
          recommend: document['recommend'],
        );
      }),
    );
    this.teachers = await teachers;
    notifyListeners();
  }
}
