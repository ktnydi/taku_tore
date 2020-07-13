import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        return User(
          uid: document.documentID,
          displayName: document['displayName'],
          photoURL: document['photoURL'],
          isTeacher: document['isTeacher'],
          createdAt: document['createdAt'],
          title: document['title'],
          about: document['about'],
          canDo: document['canDo'],
          recommend: document['recommend'],
          avgRating: document['avgRating'].toDouble(),
          numRatings: document['numRatings'],
        );
      }),
    );
    this.teachers = await teachers;
    notifyListeners();
    await endLoading();
  }
}
