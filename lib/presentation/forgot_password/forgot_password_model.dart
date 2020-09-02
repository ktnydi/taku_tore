import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class ForgotPasswordModel extends ChangeNotifier {
  final TextEditingController email = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  bool isLoading = false;
  bool isSendMail = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future sendPasswordResetEmail() async {
    await _auth.sendPasswordResetEmail(email: this.email.text);
  }

  Future showMessage() async {
    isSendMail = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 5000));

    isSendMail = false;
    notifyListeners();
  }
}
