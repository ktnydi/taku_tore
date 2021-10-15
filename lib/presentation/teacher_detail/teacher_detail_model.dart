import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/review.dart';
import 'package:takutore/domain/room.dart';
import 'package:takutore/domain/teacher.dart';
import '../../domain/user.dart';

class TeacherDetailModel extends ChangeNotifier {
  Teacher teacher;
  ScrollController scrollController = ScrollController();
  List<Review> reviews = [];
  List<DocumentSnapshot> reviewDocList = [];
  bool isBlocked = false;
  bool isAuthor = false;
  bool isBookmarked = false;
  bool isAlreadyExist = false;
  bool isAlreadyReviewed = false;
  bool isLoading = false;
  bool isCreatingRoom = false;

  void beginLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  void beginCreatingRoom() {
    this.isCreatingRoom = true;
    notifyListeners();
  }

  void endCreatingRoom() {
    this.isCreatingRoom = false;
    notifyListeners();
  }

  void scrollListener() {
    this.scrollController.addListener(() async {
      final currentScrollPosition = scrollController.offset;
      final maxScrollExtent = scrollController.position.maxScrollExtent;

      if (currentScrollPosition == maxScrollExtent) {
        await addReviews();
      }
    });
  }

  Future checkAuthor({Teacher teacher}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    this.isAuthor = teacher.uid == currentUser.uid;
    notifyListeners();
  }

  Future checkBookmark({Teacher teacher}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.get();
    this.isBookmarked = docs.docs.isNotEmpty;
    notifyListeners();
  }

  Future checkBlocked({Teacher teacher}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    this.isBlocked = teacher.blockedUserID.contains(currentUser.uid);

    notifyListeners();
  }

  Future checkReview({Teacher teacher}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(teacher.uid)
        .collection('teachers')
        .doc(teacher.uid)
        .collection('reviews')
        .where('fromUid', isEqualTo: currentUser.uid);
    final docs = await query.get();
    final isExist = docs.docs.isNotEmpty;
    this.isAlreadyReviewed = isExist;

    notifyListeners();
  }

  Future addBookmark() async {
    final user = auth.FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks');
    await collection.add({
      'teacherId': teacher.uid,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future deleteBookmark() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.get();
    final docId = docs.docs.first.id;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();
  }

  Future fetchReviews({Teacher teacher}) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(teacher.uid)
        .collection('teachers')
        .doc(teacher.uid)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(2);
    final docs = await collection.get();

    this.reviewDocList = docs.docs;

    final reviews = await Future.wait(
      docs.docs.map((doc) async {
        final document = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.data()['fromUid']);
        final data = await document.get();
        final fromUser = User(
          uid: data.data()['uid'],
          displayName: data.data()['displayName'],
          photoURL: data.data()['photoURL'],
          isTeacher: data.data()['isTeacher'],
          createdAt: data.data()['createdAt'],
          blockedUserID: data.data()['blockedUserID'],
        );
        return Review(doc.data(), fromUser);
      }),
    );
    this.reviews = reviews;

    notifyListeners();
  }

  Future addReviews() async {
    if (reviews.isEmpty) {
      return;
    }
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(teacher.uid)
        .collection('teachers')
        .doc(teacher.uid)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(reviewDocList[reviewDocList.length - 1])
        .limit(10);
    final docs = await collection.get();

    this.reviewDocList = [...this.reviewDocList, ...docs.docs];

    final extraReviews = await Future.wait(
      docs.docs.map((doc) async {
        final document = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.data()['fromUid']);
        final data = await document.get();
        final fromUser = User(
          uid: data.data()['uid'],
          displayName: data.data()['displayName'],
          photoURL: data.data()['photoURL'],
          isTeacher: data.data()['isTeacher'],
          createdAt: data.data()['createdAt'],
          blockedUserID: data.data()['blockedUserID'],
        );
        return Review(doc.data(), fromUser);
      }).toList(),
    );

    this.reviews = [...this.reviews, ...extraReviews];

    notifyListeners();
  }

  Future checkRoom({Teacher teacher}) async {
    beginLoading();
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: teacher.uid)
        .where('member.studentID', isEqualTo: currentUser.uid);
    final docs = await query.get();
    this.isAlreadyExist = docs.docs.isNotEmpty;

    endLoading();
    notifyListeners();
  }

  Future<Room> addRoom() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return null;

    if (this.teacher.uid == currentUser.uid) {
      throw ('自分には相談できません。');
    }

    final document = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .doc('${this.teacher.uid}_${currentUser.uid}');

    await document.set(
      {
        'member': {
          'teacherID': this.teacher.uid,
          'studentID': currentUser.uid,
        },
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageFromUid': '',
        'numNewMessage': 0,
        'isAllow': true,
      },
    );

    final doc = await document.get();
    final teacher = await fetchUser(id: doc.data()['member']['teacherID']);
    final student = await fetchUser(id: doc.data()['member']['studentID']);

    final room = Room(
      documentId: doc.id,
      teacher: teacher,
      student: student,
      lastMessage: doc.data()['lastMessage'],
      updatedAt: doc.data()['updatedAt'],
      createdAt: doc.data()['createdAt'],
      numNewMessage: doc.data()['numNewMessage'],
      hasNewMessage: doc.data()['numNewMessage'] > 0,
      lastMessageFromUid: doc.data()['lastMessageFromUid'],
      isAllow: doc.data()['isAllow'],
    );

    return room;
  }

  Future<User> fetchUser({String id}) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    final user = User(
      uid: userSnapshot.id,
      displayName: userSnapshot.data()['displayName'],
      photoURL: userSnapshot.data()['photoURL'],
      isTeacher: userSnapshot.data()['isTeacher'],
      createdAt: userSnapshot.data()['createdAt'],
      blockedUserID: userSnapshot.data()['blockedUserID'],
    );
    return user;
  }
}
