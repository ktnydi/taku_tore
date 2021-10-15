import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:takutore/config.dart';
import 'package:takutore/domain/teacher.dart';
import 'package:takutore/domain/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class SearchTeacherListModel extends ChangeNotifier {
  SearchTeacherListModel({this.text});

  final String text;
  final scrollController = ScrollController();
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
  final hitsPerPage = 50;
  List<Teacher> teachers = [];
  int maxPage = 0;
  int page = 0;
  bool isLoading = false;
  bool forbidScroll = false;

  beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void scrollListener() {
    scrollController.addListener(
      () async {
        final currentScrollPosition = scrollController.offset;
        final maxScrollExtent = scrollController.position.maxScrollExtent;

        if (!this.forbidScroll && currentScrollPosition == maxScrollExtent) {
          beginLoading();
          await this.nextPage();
          endLoading();
        }
      },
    );
  }

  Future searchTeachers() async {
    var query = _algolia
        .index('teacher')
        .setHitsPerPage(this.hitsPerPage)
        .setPage(this.page);
    query = query.query(this.text);
    final snap = await query.getObjects();
    if (this.page == snap.nbPages - 1) {
      this.forbidScroll = true;
    }
    this.maxPage = snap.nbPages - 1;
    this.page += 1;
    final teachers = snap.hits.map(
      (teacher) {
        return Teacher(
          uid: teacher.data['userID'],
          displayName: teacher.data['displayName'],
          photoURL: teacher.data['photoURL'],
          isTeacher: teacher.data['isTeacher'],
          blockedUserID: teacher.data['blockedUserID'],
          createdAt: teacher.data['createdAt'],
          thumbnail: teacher.data['thumbnail'],
          title: teacher.data['title'],
          about: teacher.data['about'],
          canDo: teacher.data['canDo'],
          recommend: teacher.data['recommend'],
          avgRating: teacher.data['avgRating'].toDouble(),
          numRatings: teacher.data['numRatings'].toInt(),
          isRecruiting: teacher.data['isRecruiting'],
        );
      },
    ).toList();
    this.teachers = teachers;
    notifyListeners();
  }

  Future nextPage() async {
    var query = _algolia
        .index('teacher')
        .setHitsPerPage(this.hitsPerPage)
        .setPage(this.page);
    query = query.query(this.text);
    final snap = await query.getObjects();
    if (this.page == this.maxPage) {
      this.forbidScroll = true;
    }
    this.page += 1;
    final teachers = snap.hits.map(
      (teacher) {
        return Teacher(
          uid: teacher.data['userID'],
          displayName: teacher.data['displayName'],
          photoURL: teacher.data['photoURL'],
          isTeacher: teacher.data['isTeacher'],
          blockedUserID: teacher.data['blockedUserID'],
          createdAt: teacher.data['createdAt'],
          thumbnail: teacher.data['thumbnail'],
          title: teacher.data['title'],
          about: teacher.data['about'],
          canDo: teacher.data['canDo'],
          recommend: teacher.data['recommend'],
          avgRating: teacher.data['avgRating'].toDouble(),
          numRatings: teacher.data['numRatings'].toInt(),
          isRecruiting: teacher.data['isRecruiting'],
        );
      },
    ).toList();
    this.teachers = [...this.teachers, ...teachers];
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
    // TODO: firestoreに保存し、functionsでSlackに通知する。
  }
}
