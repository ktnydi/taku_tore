import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takutore/config.dart';
import '../../domain/user.dart';

class RemoveTeacherModel extends ChangeNotifier {
  final _store = FirebaseFirestore.instance;
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
  User user;
  String _password = '';
  bool isLoading = false;

  String get password => this._password;

  set password(String value) {
    this._password = value;
    notifyListeners();
  }

  void beginLoading() async {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() async {
    isLoading = false;
    notifyListeners();
  }

  Future<auth.UserCredential> confirmPassword(password) async {
    beginLoading();
    auth.User user = auth.FirebaseAuth.instance.currentUser;
    auth.UserCredential result = await user.reauthenticateWithCredential(
      auth.EmailAuthProvider.credential(
        email: user.email,
        password: password,
      ),
    );
    endLoading();
    return result;
  }

  Future removeAsTeacher() async {
    beginLoading();
    final auth.UserCredential result = await confirmPassword(this._password);

    final userRef = _store.collection('users').doc(result.user.uid);

    final batch = _store.batch();

    batch.update(
      userRef,
      {
        'isTeacher': false,
      },
    );

    batch.delete(
      userRef.collection('teachers').doc(result.user.uid),
    );

    await batch.commit();

    await _algolia.index('teacher').object(result.user.uid).deleteObject();
    endLoading();
  }
}
