import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';

class HomeModel extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  List<User> teachers = [];
  List<DocumentSnapshot> docSnapshot = [];
  bool isLoading = false;
  bool isFetchingTeachers = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void scrollListener() {
    this.scrollController.addListener(() async {
      final currentScrollPosition = scrollController.offset;
      final maxScrollExtent = scrollController.position.maxScrollExtent;

      if (currentScrollPosition == maxScrollExtent) {
        await addExtraTeachers();
      }
    });
  }

  Future fetchTeachers() async {
    beginLoading();
    final query = Firestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .limit(50);
    final docs = await query.getDocuments();
    this.docSnapshot = docs.documents;

    final teachers = docs.documents.map((doc) {
      return User(
        uid: doc.documentID,
        displayName: doc['displayName'],
        photoURL: doc['photoURL'],
        isTeacher: doc['isTeacher'],
        createdAt: doc['createdAt'],
        thumbnail: doc['thumbnail'],
        title: doc['title'],
        about: doc['about'],
        canDo: doc['canDo'],
        recommend: doc['recommend'],
        avgRating: doc['avgRating'].toDouble(),
        numRatings: doc['numRatings'].toInt(),
      );
    }).toList();
    this.teachers = teachers;
    notifyListeners();
    endLoading();
  }

  Future addExtraTeachers() async {
    this.isFetchingTeachers = true;
    notifyListeners();

    final query = Firestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .startAfterDocument(
          this.docSnapshot[this.docSnapshot.length - 1],
        )
        .limit(50);
    final docs = await query.getDocuments();
    this.docSnapshot = [...this.docSnapshot, ...docs.documents];

    final teachers = docs.documents.map((doc) {
      return User(
        uid: doc.documentID,
        displayName: doc['displayName'],
        photoURL: doc['photoURL'],
        isTeacher: doc['isTeacher'],
        createdAt: doc['createdAt'],
        thumbnail: doc['thumbnail'],
        title: doc['title'],
        about: doc['about'],
        canDo: doc['canDo'],
        recommend: doc['recommend'],
        avgRating: doc['avgRating'].toDouble(),
        numRatings: doc['numRatings'].toInt(),
      );
    }).toList();
    this.teachers = [...this.teachers, ...teachers];

    this.isFetchingTeachers = false;
    notifyListeners();
  }
}
