import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:takutore/config.dart';
import 'package:takutore/domain/teacher.dart';

class TeacherEditModel extends ChangeNotifier {
  final _auth = auth.FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
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
    await _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('teachers')
        .doc(currentUser.uid)
        .update(
      {
        'isRecruiting': isRecruiting,
      },
    );

    await updateAlgoliaTeacher(
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
        .collection('teachers')
        .doc()
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .get();

    return roomSnapshot.docs.length > 0;
  }

  Future fetchTeacher() async {
    beginLoading();

    final currentUser = _auth.currentUser;

    final userSnapshot = await _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('teachers')
        .doc(currentUser.uid)
        .get();

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

  Future updateAlgoliaTeacher(Map<String, dynamic> data) async {
    final currentUser = _auth.currentUser;

    final teacher =
        await _algolia.index('teacher').object(currentUser.uid).getObject();

    final newTeacher = {
      ...teacher.data,
      ...data,
    };

    await _algolia
        .index('teacher')
        .object(currentUser.uid)
        .updateData(newTeacher);
  }
}
