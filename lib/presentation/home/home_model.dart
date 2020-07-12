import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';

class HomeModel extends ChangeNotifier {
  List<User> teachers = [];
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future fetchTeachers() async {
    beginLoading();
    final query = Firestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true);
    final docs = await query.getDocuments();
    final teachers = docs.documents.map((doc) {
      return User(
        uid: doc.documentID,
        displayName: doc['displayName'],
        photoURL: doc['photoURL'],
        isTeacher: doc['isTeacher'],
        createdAt: doc['createdAt'],
        title: doc['title'],
        about: doc['about'],
        canDo: doc['canDo'],
        recommend: doc['recommend'],
        avgRating: doc['avgRating'].toDouble(),
        numRatings: doc['numRatings'],
      );
    }).toList();
    this.teachers = teachers;
    notifyListeners();
    endLoading();
  }
}
