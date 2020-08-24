import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/teacher.dart';

class TeacherEditModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _store = Firestore.instance;
  Teacher teacher;
  bool isLoading = false;
  bool isRecruiting = false;

  beginLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  Future switchRecruiting(bool isRecruiting) async {
    this.isRecruiting = isRecruiting;
    final currentUser = await _auth.currentUser();
    await _store.collection('users').document(currentUser.uid).updateData(
      {
        'isRecruiting': isRecruiting,
      },
    );
    notifyListeners();
  }

  Future<bool> hasStudents() async {
    final currentUser = await _auth.currentUser();

    final roomSnapshot = await _store
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .getDocuments();

    return roomSnapshot.documents.length > 0;
  }

  Future fetchTeacher() async {
    beginLoading();

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
      numRatings: userSnapshot['numRatings'].toInt(),
      avgRating: userSnapshot['avgRating'].toDouble(),
      thumbnail: userSnapshot['thumbnail'],
      isRecruiting: userSnapshot['isRecruiting'],
    );

    this.teacher = teacher;
    this.isRecruiting = teacher.isRecruiting;

    endLoading();
  }
}
