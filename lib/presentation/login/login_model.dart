import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginModel extends ChangeNotifier {
  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FacebookLogin _facebookLogin = FacebookLogin();
  bool isLoading = false;

  Future signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return;

    isLoading = true;
    notifyListeners();

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    auth.User user = (await _auth.signInWithCredential(credential)).user;

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final deviceToken = await _messaging.getToken();
    final document = _store.collection('users').doc(user.uid);
    final isRegister = (await document.get()).exists;

    await _store.runTransaction(
      (transaction) async {
        if (!isRegister) {
          transaction.set(
            document,
            {
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'isTeacher': false,
              'blockedUserID': [],
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }

        if (deviceToken != null && deviceToken.isNotEmpty) {
          transaction.set(
            document.collection('tokens').doc(deviceToken),
            {
              'deviceToken': deviceToken,
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }
      },
    );

    isLoading = false;
    notifyListeners();
  }

  Future signInWithApple() async {
    final appleSignInIsAvailable = await SignInWithApple.isAvailable();
    if (!appleSignInIsAvailable) {
      throw ('ご利用の端末では対応していません。');
    }
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final signInAccount = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    isLoading = true;
    notifyListeners();

    final credential = OAuthProvider('apple.com').credential(
      idToken: signInAccount.identityToken,
      rawNonce: rawNonce,
    );

    final user = (await _auth.signInWithCredential(credential)).user;

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    if (signInAccount.email != null) {
      await user.updateEmail(signInAccount.email);
    }

    final deviceToken = await _messaging.getToken();
    final document = _store.collection('users').doc(user.uid);
    final isRegister = (await document.get()).exists;

    await _store.runTransaction(
      (transaction) async {
        if (!isRegister) {
          transaction.set(
            document,
            {
              'displayName': getFullName(signInAccount),
              'photoURL': await getDefaultPhotoURL(),
              'isTeacher': false,
              'blockedUserID': [],
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }

        if (deviceToken != null && deviceToken.isNotEmpty) {
          transaction.set(
            document.collection('tokens').doc(deviceToken),
            {
              'deviceToken': deviceToken,
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }
      },
    );

    isLoading = false;
    notifyListeners();
  }

  Future signInWithFacebook() async {
    final result = await _facebookLogin.logIn();

    if (result.status == FacebookLoginStatus.cancel) {
      return print('cancel');
    }

    if (result.status == FacebookLoginStatus.error) {
      return print('error');
    }

    isLoading = true;
    notifyListeners();

    final credential = auth.FacebookAuthProvider.credential(
      result.accessToken.token,
    );

    auth.User user = (await _auth.signInWithCredential(credential)).user;

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final deviceToken = await _messaging.getToken();
    final document = _store.collection('users').doc(user.uid);
    final isRegister = (await document.get()).exists;

    await _store.runTransaction(
      (transaction) async {
        if (!isRegister) {
          transaction.set(
            document,
            {
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'isTeacher': false,
              'blockedUserID': [],
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }

        if (deviceToken != null && deviceToken.isNotEmpty) {
          transaction.set(
            document.collection('tokens').doc(deviceToken),
            {
              'deviceToken': deviceToken,
              'createdAt': FieldValue.serverTimestamp(),
            },
          );
        }
      },
    );

    isLoading = false;
    notifyListeners();
  }

  String getFullName(AuthorizationCredentialAppleID credential) {
    return '${credential.givenName} ${credential.familyName}';
  }

  Future<String> getDefaultPhotoURL() async {
    final path = '/images/default.jpg';
    final photoRef = _storage.ref().child(path);
    String photoURL = await photoRef.getDownloadURL();
    return photoURL;
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
