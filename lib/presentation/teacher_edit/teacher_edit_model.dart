import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:takutore/domain/teacher.dart';

class TeacherEditModel extends ChangeNotifier {
  final _auth = auth.FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
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
    final currentUser = _auth.currentUser;
    await _store.collection('users').doc(currentUser.uid).update(
      {
        'isRecruiting': isRecruiting,
      },
    );
    notifyListeners();
  }

  Future<bool> hasStudents() async {
    final currentUser = _auth.currentUser;

    final roomSnapshot = await _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .get();

    return roomSnapshot.docs.length > 0;
  }

  Future fetchTeacher() async {
    beginLoading();

    final currentUser = _auth.currentUser;

    final userSnapshot =
        await _store.collection('users').doc(currentUser.uid).get();

    final teacher = Teacher(
      uid: userSnapshot.id,
      displayName: userSnapshot.data()['displayName'],
      photoURL: userSnapshot.data()['photoURL'],
      isTeacher: userSnapshot.data()['isTeacher'],
      createdAt: userSnapshot.data()['createdAt'],
      title: userSnapshot.data()['title'],
      canDo: userSnapshot.data()['canDo'],
      recommend: userSnapshot.data()['recommend'],
      about: userSnapshot.data()['about'],
      blockedUserID: userSnapshot.data()['blockedUserID'],
      numRatings: userSnapshot.data()['numRatings'].toInt(),
      avgRating: userSnapshot.data()['avgRating'].toDouble(),
      thumbnail: userSnapshot.data()['thumbnail'],
      isRecruiting: userSnapshot.data()['isRecruiting'],
    );

    this.teacher = teacher;
    this.isRecruiting = teacher.isRecruiting;

    endLoading();
  }
}
