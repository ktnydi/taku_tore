import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        return Teacher(
          uid: document.documentID,
          displayName: document['displayName'],
          photoURL: document['photoURL'],
          isTeacher: document['isTeacher'],
          createdAt: document['createdAt'],
          thumbnail: document['thumbnail'],
          title: document['title'],
          about: document['about'],
          canDo: document['canDo'],
          recommend: document['recommend'],
          avgRating: document['avgRating'].toDouble(),
          numRatings: document['numRatings'].toInt(),
          blockedUserID: document['blockedUserID'],
          isRecruiting: document['isRecruiting'],
        );
      }),
    );
    this.teachers = await teachers;
    notifyListeners();
    await endLoading();
  }

  Future deleteBookmark(User teacher) async {
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
    await Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .document(docId)
        .delete();

    List<User> newTeachers = List<User>.from(this.teachers);
    newTeachers.removeWhere((tc) => tc.uid == teacher.uid);
    this.teachers = newTeachers;
    notifyListeners();
  }
}
