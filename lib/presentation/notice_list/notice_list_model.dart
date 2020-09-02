import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '../../domain/notice.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class NoticeListModel extends ChangeNotifier {
  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
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

  Future readNotice() async {
    final user = _auth.currentUser;

    final newNoticeDocs = await _store
        .collection('users')
        .doc(user.uid)
        .collection('notices')
        .where('isRead', isEqualTo: false)
        .get();

    await Future.forEach(
      newNoticeDocs.docs,
      (DocumentSnapshot doc) async {
        if (doc.data()['isRead']) return;

        await doc.reference.update(
          {
            'isRead': true,
          },
        );

        await _store.collection('users').doc(user.uid).update(
          {
            'numNotices': FieldValue.increment(-1),
          },
        );

        final userDoc = await _store.collection('users').doc(user.uid).get();

        final badgeCounter = userDoc.data()['numNotices'];

        FlutterAppBadger.updateBadgeCount(badgeCounter);
      },
    );
  }

  Future fetchNotices() async {
    this.beginLoading();

    final user = _auth.currentUser;

    final noticeDocs = await _store
        .collection('users')
        .doc(user.uid)
        .collection('notices')
        .get();

    final notices = await Future.wait(
      noticeDocs.docs.map(
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
    final document = _store.collection('users').doc(uid);
    final doc = await document.get();
    final user = User(
      uid: doc.id,
      displayName: doc.data()['displayName'],
      photoURL: doc.data()['photoURL'],
      isTeacher: doc.data()['isTeacher'],
      createdAt: doc.data()['createdAt'],
      blockedUserID: doc.data()['blockedUserID'],
    );
    return user;
  }

  Future fetchRoom({Notice notice}) async {
    final user = _auth.currentUser;

    final document = _store
        .collection('users')
        .doc(user.uid)
        .collection('rooms')
        .doc(notice.data['documentID']);
    final doc = await document.get();
    final teacher =
        await _fetchUserFromFirebase(uid: doc.data()['member']['teacherID']);
    final student =
        await _fetchUserFromFirebase(uid: doc.data()['member']['studentID']);
    final room = Room(
      documentId: doc.id,
      teacher: teacher,
      student: student,
      lastMessage: doc.data()['lastMessage'],
      updatedAt: doc.data()['updatedAt'],
      createdAt: doc.data()['createdAt'],
      lastMessageFromUid: doc.data()['lastMessageFromUid'],
      numNewMessage: doc.data()['numNewMessage'],
      hasNewMessage: doc.data()['numNewMessage'].toDouble() > 0,
      isAllow: doc.data()['isAllow'],
    );
    this.room = room;
    notifyListeners();
  }
}
