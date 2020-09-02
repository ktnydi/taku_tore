import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:takutore/domain/user.dart';

class BlockedUserListModel extends ChangeNotifier {
  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  List<User> blockedUsers = [];
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future removeBlock({User user}) async {
    final currentUser = _auth.currentUser;
    final document = _store.collection('users').doc(currentUser.uid);
    await document.update(
      {
        'blockedUserID': FieldValue.arrayRemove([user.uid]),
      },
    );
  }

  Future fetchBlockedUsers() async {
    beginLoading();

    final currentUser = _auth.currentUser;
    final document = _store.collection('users').doc(currentUser.uid);
    final doc = await document.get();
    List<dynamic> blockedUserID = doc.data()['blockedUserID'];

    final blockedUsers = await Future.wait(blockedUserID.map(
      (userID) async {
        final userDoc = _store.collection('users').doc(userID);
        final data = await userDoc.get();
        return User(
          uid: data.id,
          displayName: data.data()['displayName'],
          photoURL: data.data()['photoURL'],
          isTeacher: data.data()['isTeacher'],
          createdAt: data.data()['createdAt'],
          blockedUserID: data.data()['blockedUserID'],
        );
      },
    ));
    this.blockedUsers = blockedUsers;

    endLoading();
  }
}
