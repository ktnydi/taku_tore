import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/user.dart';

class TeacherDetailModel extends ChangeNotifier {
  User teacher;
  bool isBookmarked = false;
  bool isAlreadyExist = false;

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

  Future checkRoom({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final roomQuery = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.teacherId', isEqualTo: teacher.uid);

    final docs = await roomQuery.getDocuments();
    final isExist = docs.documents.isNotEmpty;
    this.isAlreadyExist = isExist;
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

  Future addRoom() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (teacher.uid == currentUser.uid) {
      throw ('自分には相談できません。');
    }

    final roomRef = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms');

    final roomQuery = roomRef.where('member.teacherId', isEqualTo: teacher.uid);
    final docs = await roomQuery.getDocuments();
    final isExist = docs.documents.isNotEmpty;

    if (isExist) {
      throw ('すでに相談済みです。');
    }

    await roomRef.add({
      'member': {
        'teacherId': teacher.uid,
        'studentId': currentUser.uid,
      },
    });
  }
}
