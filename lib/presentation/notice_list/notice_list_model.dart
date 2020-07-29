import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/notice.dart';

class NoticeListModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _store = Firestore.instance;
  List<Notice> notices = [];
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
          return notice;
        },
      ),
    );

    this.notices = notices;

    this.endLoading();
  }
}
