import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LoginEmailModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseMessaging _message = FirebaseMessaging();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    final List<TextEditingController> _controllers = [
      emailController,
      passwordController,
    ];
    _controllers.forEach(
      (_controller) => _controller.dispose(),
    );
    myFocusNode.dispose();
  }

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future loginWithEmail() async {
    final user = (await _auth.signInWithEmailAndPassword(
      email: this.emailController.text,
      password: this.passwordController.text,
    ))
        .user;

    if (user == null) {
      endLoading();
      return;
    }

    final deviceToken = await _message.getToken();

    if (deviceToken != null && deviceToken.isNotEmpty) {
      final document = _store
          .collection('users')
          .doc(user.uid)
          .collection('tokens')
          .doc(deviceToken);
      await document.set(
        {
          'deviceToken': deviceToken,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    }
  }
}
