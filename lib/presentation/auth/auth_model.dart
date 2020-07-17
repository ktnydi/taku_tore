import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _store = Firestore.instance;
  FirebaseMessaging _messaging = FirebaseMessaging();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isLoading = false;

  Future signUpWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return;

    isLoading = true;
    notifyListeners();

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    bool registered = await hasAlreadyRegistered(userID: user.uid);

    if (user != null && !registered) {
      final deviceToken = await _messaging.getToken();
      await _store.collection('users').document(user.uid).setData(
        {
          'displayName': user.displayName,
          'photoURL': user.photoUrl,
          'isTeacher': false,
          'deviceToken': deviceToken,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> hasAlreadyRegistered({String userID}) async {
    final user = _store.collection('users').document(userID);
    final doc = await user.get();
    return doc.exists;
  }
}
