import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/teacher.dart';
import 'package:takutore/domain/user.dart';

class TeacherEditModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _store = Firestore.instance;
  User teacher;
  bool isLoading = false;

  beginLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  Future fetchTeacher() async {
    final currentUser = await _auth.currentUser();

    final userSnapshot =
        await _store.collection('users').document(currentUser.uid).get();

    final teacher = Teacher(
      uid: userSnapshot.documentID,
      displayName: userSnapshot['displayName'],
      photoURL: userSnapshot['photoURL'],
      isTeacher: userSnapshot['isTeacher'],
      createdAt: userSnapshot['createdAt'],
      title: userSnapshot['title'],
      canDo: userSnapshot['canDo'],
      recommend: userSnapshot['recommend'],
      about: userSnapshot['about'],
      blockedUserID: userSnapshot['blockedUserID'],
      numRatings: userSnapshot['numRatings'],
      avgRating: userSnapshot['avgRating'],
      thumbnail: userSnapshot['thumbnail'],
    );

    this.teacher = teacher;
    notifyListeners();
  }

  Future stopConsulting(consult) async {
    final currentUser = await _auth.currentUser();
    await _store.collection('users').document(currentUser.uid).updateData(
      {
        'isTeacher': !consult,
      },
    );
    print(consult);
    notifyListeners();
  }
}
