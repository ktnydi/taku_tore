import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:takutore/domain/user.dart';

class BlockedUserListModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _store = Firestore.instance;
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
    final currentUser = await _auth.currentUser();
    final document = _store.collection('users').document(currentUser.uid);
    await document.updateData(
      {
        'blockedUserID': FieldValue.arrayRemove([user.uid]),
      },
    );
  }

  Future fetchBlockedUsers() async {
    beginLoading();

    final currentUser = await _auth.currentUser();
    final document = _store.collection('users').document(currentUser.uid);
    final doc = await document.get();
    List<dynamic> blockedUserID = doc['blockedUserID'];

    final blockedUsers = await Future.wait(blockedUserID.map(
      (userID) async {
        final userDoc = _store.collection('users').document(userID);
        final data = await userDoc.get();
        return User(
          uid: data.documentID,
          displayName: data['displayName'],
          photoURL: data['photoURL'],
          isTeacher: data['isTeacher'],
          createdAt: data['createdAt'],
        );
      },
    ));
    this.blockedUsers = blockedUsers;

    endLoading();
  }
}
