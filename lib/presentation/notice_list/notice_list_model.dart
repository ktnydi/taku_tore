import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/notice.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class NoticeListModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _store = Firestore.instance;
  List<Notice> notices = [];
  Room room;
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future fetchNotices() async {
    this.beginLoading();

    final user = await _auth.currentUser();

    final collection =
        _store.collection('users').document(user.uid).collection('notices');

    final docs = await collection.getDocuments();

    final notices = await Future.wait(
      docs.documents.map(
        (doc) async {
          final notice = Notice(doc);
          await notice.fetchSender();
          if (notice.type == 'add room') {
            await this.fetchRoom(notice: notice);
          }
          return notice;
        },
      ),
    );

    this.notices = notices;

    this.endLoading();
  }

  Future<User> _fetchUserFromFirebase({String uid}) async {
    final document = _store.collection('users').document(uid);
    final doc = await document.get();
    final user = User(
      uid: doc.documentID,
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      isTeacher: doc['isTeacher'],
      createdAt: doc['createdAt'],
      blockedUserID: doc['blockedUserID'],
    );
    return user;
  }

  Future fetchRoom({Notice notice}) async {
    final document = _store
        .collection('users')
        .document(notice.data['senderID'])
        .collection('rooms')
        .document(notice.data['roomID']);
    final doc = await document.get();
    final teacher =
        await _fetchUserFromFirebase(uid: doc['member']['teacherID']);
    final student =
        await _fetchUserFromFirebase(uid: doc['member']['studentID']);
    final room = Room(
      documentId: doc.documentID,
      teacher: teacher,
      student: student,
      lastMessage: doc['lastMessage'],
      updatedAt: doc['updatedAt'],
      createdAt: doc['createdAt'],
      lastMessageFromUid: doc['lastMessageFromUid'],
      hasNewMessage: doc['numNewMessage'].toDouble() > 0,
      isAllow: doc['isAllow'],
    );
    this.room = room;
    notifyListeners();
  }
}
