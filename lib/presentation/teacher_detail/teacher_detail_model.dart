import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/review.dart';
import 'package:takutore/domain/room.dart';
import '../../domain/user.dart';

class TeacherDetailModel extends ChangeNotifier {
  User teacher;
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

  Future checkAuthor({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    this.isAuthor = teacher.uid == currentUser.uid;
    notifyListeners();
  }

  Future checkBookmark({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final query = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.getDocuments();
    this.isBookmarked = docs.documents.isNotEmpty;
    notifyListeners();
  }

  Future checkBlocked({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    this.isBlocked = teacher.blockedUserID.contains(currentUser.uid);

    notifyListeners();
  }

  Future checkReview({User teacher}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final query = Firestore.instance
        .collection('users')
        .document(teacher.uid)
        .collection('reviews')
        .where('fromUid', isEqualTo: currentUser.uid);
    final docs = await query.getDocuments();
    final isExist = docs.documents.isNotEmpty;
    this.isAlreadyReviewed = isExist;

    notifyListeners();
  }

  Future addBookmark() async {
    final user = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('bookmarks');
    await collection.add({
      'teacherId': teacher.uid,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future deleteBookmark() async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final query = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .where(
          'teacherId',
          isEqualTo: teacher.uid,
        );
    final docs = await query.getDocuments();
    final docId = docs.documents.first.documentID;
    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('bookmarks')
        .document(docId)
        .delete();
  }

  Future fetchReviews({User teacher}) async {
    final collection = Firestore.instance
        .collection('users')
        .document(teacher.uid)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(2);
    final docs = await collection.getDocuments();

    this.reviewDocList = docs.documents;

    final reviews = await Future.wait(
      docs.documents.map((doc) async {
        final document =
            Firestore.instance.collection('users').document(doc['fromUid']);
        final data = await document.get();
        final fromUser = User(
          uid: data['uid'],
          displayName: data['displayName'],
          photoURL: data['photoURL'],
          isTeacher: data['isTeacher'],
          createdAt: data['createdAt'],
        );
        return Review(doc, fromUser);
      }),
    );
    this.reviews = reviews;

    notifyListeners();
  }

  Future addReviews() async {
    if (reviews.isEmpty) {
      return;
    }
    final collection = Firestore.instance
        .collection('users')
        .document(teacher.uid)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(reviewDocList[reviewDocList.length - 1])
        .limit(10);
    final docs = await collection.getDocuments();

    this.reviewDocList = [...this.reviewDocList, ...docs.documents];

    final extraReviews = await Future.wait(
      docs.documents.map((doc) async {
        final document =
            Firestore.instance.collection('users').document(doc['fromUid']);
        final data = await document.get();
        final fromUser = User(
          uid: data['uid'],
          displayName: data['displayName'],
          photoURL: data['photoURL'],
          isTeacher: data['isTeacher'],
          createdAt: data['createdAt'],
        );
        return Review(doc, fromUser);
      }).toList(),
    );

    this.reviews = [...this.reviews, ...extraReviews];

    notifyListeners();
  }

  Future checkRoom({User teacher}) async {
    beginLoading();
    final currentUser = await FirebaseAuth.instance.currentUser();

    final query = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .where('member.teacherID', isEqualTo: teacher.uid)
        .where('member.studentID', isEqualTo: currentUser.uid);
    final docs = await query.getDocuments();
    this.isAlreadyExist = docs.documents.isNotEmpty;

    endLoading();
    notifyListeners();
  }

  Future<Room> addRoom() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (this.teacher.uid == currentUser.uid) {
      throw ('自分には相談できません。');
    }

    final document = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document('${this.teacher.uid}_${currentUser.uid}');

    await document.setData(
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
    final teacher = await fetchUser(id: doc['member']['teacherID']);
    final student = await fetchUser(id: doc['member']['studentID']);

    final room = Room(
      documentId: doc.documentID,
      teacher: teacher,
      student: student,
      lastMessage: doc['lastMessage'],
      updatedAt: doc['updatedAt'],
      createdAt: doc['createdAt'],
      numNewMessage: doc['numNewMessage'],
      hasNewMessage: doc['numNewMessage'] > 0,
      lastMessageFromUid: doc['lastMessageFromUid'],
      isAllow: doc['isAllow'],
    );

    return room;
  }

  Future<User> fetchUser({String id}) async {
    final userSnapshot =
        await Firestore.instance.collection('users').document(id).get();
    final user = User(
      uid: userSnapshot.documentID,
      displayName: userSnapshot['displayName'],
      photoURL: userSnapshot['photoURL'],
      isTeacher: userSnapshot['isTeacher'],
      createdAt: userSnapshot['createdAt'],
    );
    return user;
  }
}
