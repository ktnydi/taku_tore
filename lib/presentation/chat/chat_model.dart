import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatModel extends ChangeNotifier {
  final String tabName;
  ScrollController teacherScroll = ScrollController();
  ScrollController studentScroll = ScrollController();
  List<DocumentSnapshot> teacherSnapshot = [];
  List<DocumentSnapshot> studentSnapshot = [];
  List<Room> teacherRooms = [];
  List<Room> studentRooms = [];
  bool isLoading = false;

  ChatModel({this.tabName});

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
    switch (tabName) {
      case 'teacher':
        teacherScrollListener();
        break;
      case 'student':
        studentScrollListener();
        break;
    }
  }

  Future<User> fetchUserFromFirebase({@required String userId}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final user = await userRef.get();
    return User(
      uid: user.id,
      displayName: user.data()['displayName'],
      photoURL: user.data()['photoURL'],
      isTeacher: user.data()['isTeacher'],
      createdAt: user.data()['createdAt'],
      blockedUserID: user.data()['blockedUserID'],
    );
  }

  Future<Room> convertSnapshotToDomain({DocumentSnapshot doc}) async {
    final map = doc.data() as Map<String, dynamic>;
    final teacherID = map['member']['teacherID'];
    final studentID = map['member']['studentID'];

    final teacher = await fetchUserFromFirebase(userId: teacherID);
    final student = await fetchUserFromFirebase(userId: studentID);

    return Room(
      documentId: doc.id,
      teacher: teacher,
      student: student,
      lastMessage: map['lastMessage'],
      updatedAt: map['updatedAt'],
      createdAt: map['createdAt'],
      lastMessageFromUid: map['lastMessageFromUid'],
      numNewMessage: map['numNewMessage'],
      hasNewMessage: map['numNewMessage'].toDouble() > 0,
      isAllow: map['isAllow'],
    );
  }

  Future fetchTeacherRooms() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.studentID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50);
    final docs = await collection.get();
    this.teacherSnapshot = docs.docs;

    final rooms = await Future.wait(
      docs.docs.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.teacherRooms = rooms;
  }

  Future fetchExtraTeacherRooms() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.studentID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(
          this.teacherSnapshot[this.teacherSnapshot.length - 1],
        )
        .limit(50);
    final docs = await collection.get();
    this.teacherSnapshot = [...this.teacherSnapshot, ...docs.docs];

    final rooms = await Future.wait(
      docs.docs.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.teacherRooms = [...this.teacherRooms, ...rooms];

    notifyListeners();
  }

  Future fetchStudentRooms() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('teachers')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50);
    final docs = await collection.get();
    this.studentSnapshot = docs.docs;

    final rooms = await Future.wait(
      docs.docs.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.studentRooms = rooms;
  }

  Future fetchExtraStudentRooms() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('teachers')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(
          this.studentSnapshot[this.studentSnapshot.length - 1],
        )
        .limit(50);
    final docs = await collection.get();
    this.studentSnapshot = [...this.studentSnapshot, ...docs.docs];

    final rooms = await Future.wait(
      docs.docs.map(
        (doc) async => await convertSnapshotToDomain(doc: doc),
      ),
    );
    this.studentRooms = [...this.studentRooms, ...rooms];

    notifyListeners();
  }

  Future fetchRooms() async {
    beginLoading();

    switch (tabName) {
      case 'teacher':
        await this.fetchTeacherRooms();
        break;
      case 'student':
        await this.fetchStudentRooms();
        break;
    }

    endLoading();
    notifyListeners();
  }
}
