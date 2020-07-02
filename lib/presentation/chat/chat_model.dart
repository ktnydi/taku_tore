import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatModel extends ChangeNotifier {
  List<Room> rooms = [];
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<User> fetchUserFromFirebase({@required String userId}) async {
    final userRef = Firestore.instance.collection('users').document(userId);
    final user = await userRef.get();
    return User(
      uid: user.documentID,
      displayName: user['displayName'],
      photoURL: user['photoURL'],
      isTeacher: user['isTeacher'],
      createdAt: user['createdAt'],
      about: user['about'],
      canDo: user['canDo'],
      recommend: user['recommend'],
    );
  }

  Future fetchRooms() async {
    beginLoading();
    final currentUser = await FirebaseAuth.instance.currentUser();

    final roomRef = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms');
    final roomDocs = await roomRef.getDocuments();
    final rooms = Future.wait(
      roomDocs.documents.map((doc) async {
        final teacherId = doc['member']['teacherId'];
        final studentId = doc['member']['studentId'];

        final teacher = await fetchUserFromFirebase(userId: teacherId);
        final student = await fetchUserFromFirebase(userId: studentId);

        return Room(
          documentId: doc.documentID,
          teacher: teacher,
          student: student,
        );
      }),
    );
    this.rooms = await rooms;
    notifyListeners();
    endLoading();
  }
}
