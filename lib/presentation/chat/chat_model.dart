import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatModel extends ChangeNotifier {
  List<Room> teacherRooms = [];
  List<Room> studentRooms = [];
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

  Future<List<Room>> fetchRoomsFromFirebase({dynamic field}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('rooms')
        .where(field, isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true);
    final docs = await collection.getDocuments();

    final rooms = await Future.wait(
      docs.documents.map((doc) async {
        final teacherID = doc['member']['teacherID'];
        final studentID = doc['member']['studentID'];

        final teacher = await fetchUserFromFirebase(userId: teacherID);
        final student = await fetchUserFromFirebase(userId: studentID);

        return Room(
          documentId: doc.documentID,
          teacher: teacher,
          student: student,
          lastMessage: doc['lastMessage'],
          updatedAt: doc['updatedAt'],
          createdAt: doc['createdAt'],
        );
      }),
    );
    return rooms;
  }

  Future fetchRooms() async {
    beginLoading();

    this.teacherRooms = await fetchRoomsFromFirebase(field: 'member.studentID');
    this.studentRooms = await fetchRoomsFromFirebase(field: 'member.teacherID');

    notifyListeners();
    endLoading();
  }
}
