import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:takutore/domain/teacher.dart';
import '../../domain/user.dart';

class BookmarkModel extends ChangeNotifier {
  List<User> teachers = [];
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  Future endLoading() async {
    isLoading = false;
    notifyListeners();
  }

  Future fetchBookmarks() async {
    beginLoading();
    final user = auth.FirebaseAuth.instance.currentUser;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks');
    final docs = await collection.get();
    final teachers = Future.wait(
      docs.docs.map((doc) async {
        final teacherRef = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.data()['teacherId'])
            .collection('teachers')
            .doc(doc.data()['teacherId']);
        final document = await teacherRef.get();
        return Teacher(
          uid: document.id,
          displayName: document.data()['displayName'],
          photoURL: document.data()['photoURL'],
          isTeacher: document.data()['isTeacher'],
          createdAt: document.data()['createdAt'],
          thumbnail: document.data()['thumbnail'],
          title: document.data()['title'],
          about: document.data()['about'],
          canDo: document.data()['canDo'],
          recommend: document.data()['recommend'],
          avgRating: document.data()['avgRating'].toDouble(),
          numRatings: document.data()['numRatings'].toInt(),
          blockedUserID: document.data()['blockedUserID'],
          isRecruiting: document.data()['isRecruiting'],
        );
      }),
    );
    this.teachers = await teachers;
    notifyListeners();
    await endLoading();
  }

  Future deleteBookmark(User teacher) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();

    List<User> newTeachers = List<User>.from(this.teachers);
    newTeachers.removeWhere((tc) => tc.uid == teacher.uid);
    this.teachers = newTeachers;
    notifyListeners();
  }

  Future blockedUser({User user}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final document =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    await document.update(
      {
        'blockedUserID': FieldValue.arrayUnion(
          [user.uid],
        ),
      },
    );
  }

  Future report({User user, String contentType}) async {
    final contentTypes = ['inappropriate', 'spam'];

    if (!contentTypes.contains(contentType)) return;

    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null || user.uid == currentUser.uid) return;

    final collection = FirebaseFirestore.instance.collection('reports');

    final result = await collection.add(
      {
        'userID': user.uid,
        'senderID': currentUser.uid,
        'contentType': contentType,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    final doc = await result.get();

    // gasで作成したgssに報告データを追加するweb apiを呼ぶ
    final webAppURL = DotEnv().env['GOOGLE_WEB_APP_URL'];
    http.post(
      webAppURL,
      body: {
        'documentID': doc.id,
        'userID': doc.data()['userID'],
        'senderID': doc.data()['senderID'],
        'contentType': doc.data()['contentType'],
        'createdAt': doc.data()['createdAt'].toDate().toString(),
      },
    );
  }
}
