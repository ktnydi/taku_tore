import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/user.dart';

class HomeModel extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  List<User> teachers = [];
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
    final query = Firestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .limit(50);
    final docs = await query.getDocuments();
    this.docSnapshot = docs.documents;

    final teachers = docs.documents.map((doc) {
      return User(
        uid: doc.documentID,
        displayName: doc['displayName'],
        photoURL: doc['photoURL'],
        isTeacher: doc['isTeacher'],
        createdAt: doc['createdAt'],
        thumbnail: doc['thumbnail'],
        title: doc['title'],
        about: doc['about'],
        canDo: doc['canDo'],
        recommend: doc['recommend'],
        avgRating: doc['avgRating'].toDouble(),
        numRatings: doc['numRatings'].toInt(),
        blockedUserID: doc['blockedUserID'],
      );
    }).toList();

    this.teachers = teachers;
    notifyListeners();
  }

  Future addExtraTeachers() async {
    this.isFetchingTeachers = true;
    notifyListeners();

    final query = Firestore.instance
        .collection('users')
        .where('isTeacher', isEqualTo: true)
        .orderBy('avgRating', descending: true)
        .startAfterDocument(
          this.docSnapshot[this.docSnapshot.length - 1],
        )
        .limit(50);
    final docs = await query.getDocuments();
    this.docSnapshot = [...this.docSnapshot, ...docs.documents];

    final teachers = docs.documents.map((doc) {
      return User(
        uid: doc.documentID,
        displayName: doc['displayName'],
        photoURL: doc['photoURL'],
        isTeacher: doc['isTeacher'],
        createdAt: doc['createdAt'],
        thumbnail: doc['thumbnail'],
        title: doc['title'],
        about: doc['about'],
        canDo: doc['canDo'],
        recommend: doc['recommend'],
        avgRating: doc['avgRating'].toDouble(),
        numRatings: doc['numRatings'].toInt(),
      );
    }).toList();
    this.teachers = [...this.teachers, ...teachers];

    this.isFetchingTeachers = false;
    notifyListeners();
  }

  Future checkBlockedUser() async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final document =
        Firestore.instance.collection('users').document(currentUser.uid);
    final doc = await document.get();
    final blockedUserID = doc['blockedUserID'];
    this.blockedUserID = blockedUserID;
  }

  Future blockedUser({User user}) async {
    final currentUser = await FirebaseAuth.instance.currentUser();
    final document =
        Firestore.instance.collection('users').document(currentUser.uid);

    await document.updateData(
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

    final currentUser = await FirebaseAuth.instance.currentUser();

    if (user.uid == currentUser.uid) return;

    final collection = Firestore.instance.collection('reports');

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
        'documentID': doc.documentID,
        'userID': doc['userID'],
        'senderID': doc['senderID'],
        'contentType': doc['contentType'],
        'createdAt': doc['createdAt'].toDate().toString(),
      },
    );
  }
}
