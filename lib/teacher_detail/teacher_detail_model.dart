import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../user.dart';

class TeacherDetailModel extends ChangeNotifier {
  User teacher;
  bool isBookmarked = false;

  Future checkBookmark({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final query = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.getDocuments();
    this.isBookmarked = docs.documents.isNotEmpty;
    notifyListeners();
  }

  Future addBookmark() async {
    final user = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('bookmarks');
    await collection.add({
      'teacherId': teacher.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future deleteBookmark() async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final query = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.getDocuments();
    final docId = docs.documents.first.documentID;
    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .document(docId)
        .delete();
  }
}
