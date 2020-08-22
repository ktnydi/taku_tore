import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatModel extends ChangeNotifier {
  ScrollController teacherScroll = ScrollController();
  ScrollController studentScroll = ScrollController();
  List<DocumentSnapshot> teacherSnapshot = [];
  List<DocumentSnapshot> studentSnapshot = [];
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

  void teacherScrollListener() {
    this.teacherScroll.addListener(() async {
      final currentScrollPosition = this.teacherScroll.offset;
      final maxScrollExtent = this.teacherScroll.position.maxScrollExtent;

      if (currentScrollPosition == maxScrollExtent) {
        await this.fetchExtraTeacherRooms();
      }
    });
  }

  void studentScrollListener() {
    this.studentScroll.addListener(() async {
      final currentScrollPosition = this.studentScroll.offset;
      final maxScrollExtent = this.studentScroll.position.maxScrollExtent;

      if (currentScrollPosition == maxScrollExtent) {
        await this.fetchExtraStudentRooms();
      }
    });
  }

  void scrollListener() {
    teacherScrollListener();
    studentScrollListener();
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
      blockedUserID: user['blockedUserID'],
    );
  }

  Future<Room> convertSnapshotToDomain({DocumentSnapshot doc}) async {
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
      lastMessageFromUid: doc['lastMessageFromUid'],
      numNewMessage: doc['numNewMessage'],
      hasNewMessage: doc['numNewMessage'].toDouble() > 0,
      isAllow: doc['isAllow'],
    );
  }

  Future fetchTeacherRooms() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.studentID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50);
    final docs = await collection.getDocuments();
    this.teacherSnapshot = docs.documents;

    final rooms = await Future.wait(
      docs.documents.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.teacherRooms = rooms;
  }

  Future fetchExtraTeacherRooms() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.studentID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(
          this.teacherSnapshot[this.teacherSnapshot.length - 1],
        )
        .limit(50);
    final docs = await collection.getDocuments();
    this.teacherSnapshot = [...this.teacherSnapshot, ...docs.documents];

    final rooms = await Future.wait(
      docs.documents.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.teacherRooms = [...this.teacherRooms, ...rooms];

    notifyListeners();
  }

  Future fetchStudentRooms() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50);
    final docs = await collection.getDocuments();
    this.studentSnapshot = docs.documents;

    final rooms = await Future.wait(
      docs.documents.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.studentRooms = rooms;
  }

  Future fetchExtraStudentRooms() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(
          this.studentSnapshot[this.studentSnapshot.length - 1],
        )
        .limit(50);
    final docs = await collection.getDocuments();
    this.studentSnapshot = [...this.studentSnapshot, ...docs.documents];

    final rooms = await Future.wait(
      docs.documents.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.studentRooms = [...this.studentRooms, ...rooms];

    notifyListeners();
  }

  Future fetchRooms() async {
    beginLoading();

    await this.fetchTeacherRooms();
    await this.fetchStudentRooms();

    endLoading();
    notifyListeners();
  }
}
