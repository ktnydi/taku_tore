import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:takutore/domain/teacher.dart';
import '../../domain/user.dart';

class HomeModel extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  List<Teacher> teachers = [];
  List<dynamic> blockedUserID = [];
  List<DocumentSnapshot> docSnapshot = [];
  bool isLoading = false;
  bool isFetchingTeachers = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void scrollListener() {
    this.scrollController.addListener(() async {
      final currentScrollPosition = scrollController.offset;
      final maxScrollExtent = scrollController.position.maxScrollExtent;

      if (currentScrollPosition == maxScrollExtent) {
        await addExtraTeachers();
      }
    });
  }

  Future loading() async {
    beginLoading();

    await checkBlockedUser();
    await fetchTeachers();

    endLoading();
  }

  Future fetchTeachers() async {
    final query = FirebaseFirestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .limit(50);
    final docs = await query.get();
    this.docSnapshot = docs.docs;

    final teachers = docs.docs.map((doc) {
      return Teacher(
        uid: doc.id,
        displayName: doc.data()['displayName'],
        photoURL: doc.data()['photoURL'],
        isTeacher: doc.data()['isTeacher'],
        createdAt: doc.data()['createdAt'],
        thumbnail: doc.data()['thumbnail'],
        title: doc.data()['title'],
        about: doc.data()['about'],
        canDo: doc.data()['canDo'],
        recommend: doc.data()['recommend'],
        avgRating: doc.data()['avgRating'].toDouble(),
        numRatings: doc.data()['numRatings'].toInt(),
        blockedUserID: doc.data()['blockedUserID'],
        isRecruiting: doc.data()['isRecruiting'],
      );
    }).toList();

    this.teachers = teachers;
    notifyListeners();
  }

  Future addExtraTeachers() async {
    this.isFetchingTeachers = true;
    notifyListeners();

    final query = FirebaseFirestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .startAfterDocument(
          this.docSnapshot[this.docSnapshot.length - 1],
        )
        .limit(50);
    final docs = await query.get();
    this.docSnapshot = [...this.docSnapshot, ...docs.docs];

    final teachers = docs.docs.map((doc) {
      return Teacher(
        uid: doc.id,
        displayName: doc.data()['displayName'],
        photoURL: doc.data()['photoURL'],
        isTeacher: doc.data()['isTeacher'],
        createdAt: doc.data()['createdAt'],
        thumbnail: doc.data()['thumbnail'],
        title: doc.data()['title'],
        about: doc.data()['about'],
        canDo: doc.data()['canDo'],
        recommend: doc.data()['recommend'],
        avgRating: doc.data()['avgRating'].toDouble(),
        numRatings: doc.data()['numRatings'].toInt(),
        blockedUserID: doc.data()['blockedUserID'],
        isRecruiting: doc.data()['isRecruiting'],
      );
    }).toList();
    this.teachers = [...this.teachers, ...teachers];

    this.isFetchingTeachers = false;
    notifyListeners();
  }

  Future checkBlockedUser() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final document =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final doc = await document.get();
    final blockedUserID = doc.data()['blockedUserID'];
    this.blockedUserID = blockedUserID;
  }

  Future blockedUser({User user}) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
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

    if (user.uid == currentUser.uid) return;

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
