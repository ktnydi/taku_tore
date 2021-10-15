import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SignUpEmailModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _message = FirebaseMessaging.instance;
  bool isObscureText = true;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    final List<TextEditingController> _controllers = [
      nameController,
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

  void toggleObscureText() {
    this.isObscureText = !this.isObscureText;
    notifyListeners();
  }

  Future signUpWithEmail() async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: this.emailController.text,
      password: this.passwordController.text,
    );

    if (result.user != null) {
      final path = '/images/default.jpg';
      final photoRef = _storage.ref().child(path);
      String photoURL = await photoRef.getDownloadURL();
      final deviceToken = await _message.getToken();

      await _store.runTransaction(
        (transaction) async {
          transaction.set(
            _store.collection('users').doc(result.user.uid),
            {
              'displayName': this.nameController.text,
              'photoURL': photoURL,
              'isTeacher': false,
              'blockedUserID': [],
              'createdAt': FieldValue.serverTimestamp(),
            },
          );

          if (deviceToken != null || deviceToken.isNotEmpty) {
            transaction.set(
              _store
                  .collection('users')
                  .doc(result.user.uid)
                  .collection('tokens')
                  .doc(deviceToken),
              {
                'deviceToken': deviceToken,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );
          }
        },
      );

      await result.user.sendEmailVerification();
    }
  }
}
