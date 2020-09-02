import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';

class RemoveTeacherModel extends ChangeNotifier {
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

    final doc =
        FirebaseFirestore.instance.collection('users').doc(result.user.uid);

    await doc.update({
      'isTeacher': false,
      'thumbnail': FieldValue.delete(),
      'title': FieldValue.delete(),
      'canDo': FieldValue.delete(),
      'recommend': FieldValue.delete(),
      'about': FieldValue.delete(),
      'avgRating': FieldValue.delete(),
      'numRatings': FieldValue.delete(),
      'isRecruiting': FieldValue.delete(),
    });
    endLoading();
  }
}
