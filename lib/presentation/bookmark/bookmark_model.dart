import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:takutore/domain/teacher.dart';
import '../../domain/user.dart';

class BookmarkModel extends ChangeNotifier {
  List<User> teachers = [];
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  Future endLoading() async {
    isLoading = false;
    notifyListeners();
  }

  Future fetchBookmarks() async {
    beginLoading();
    final user = auth.FirebaseAuth.instance.currentUser;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks');
    final docs = await collection.get();
    final teachers = Future.wait(
      docs.docs.map((doc) async {
        final teacherRef = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.data()['teacherId']);
        final document = await teacherRef.get();
        return Teacher(
          uid: document.id,
          displayName: document.data()['displayName'],
          photoURL: document.data()['photoURL'],
          isTeacher: document.data()['isTeacher'],
          createdAt: document.data()['createdAt'],
          thumbnail: document.data()['thumbnail'],
          title: document.data()['title'],
          about: document.data()['about'],
          canDo: document.data()['canDo'],
          recommend: document.data()['recommend'],
          avgRating: document.data()['avgRating'].toDouble(),
          numRatings: document.data()['numRatings'].toInt(),
          blockedUserID: document.data()['blockedUserID'],
          isRecruiting: document.data()['isRecruiting'],
        );
      }),
    );
    this.teachers = await teachers;
    notifyListeners();
    await endLoading();
  }

  Future deleteBookmark(User teacher) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.get();
    final docId = docs.docs.first.id;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();

    List<User> newTeachers = List<User>.from(this.teachers);
    newTeachers.removeWhere((tc) => tc.uid == teacher.uid);
    this.teachers = newTeachers;
    notifyListeners();
  }
}
