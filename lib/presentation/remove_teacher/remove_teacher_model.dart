import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<AuthResult> confirmPassword(password) async {
    beginLoading();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    AuthResult result = await user.reauthenticateWithCredential(
      EmailAuthProvider.getCredential(
        email: user.email,
        password: password,
      ),
    );
    endLoading();
    return result;
  }

  Future removeAsTeacher() async {
    beginLoading();
    final AuthResult result = await confirmPassword(this._password);

    final doc =
        Firestore.instance.collection('users').document(result.user.uid);

    await doc.updateData({
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
