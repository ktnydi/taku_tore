import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginModel extends ChangeNotifier {
  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseMessaging _messaging = FirebaseMessaging();
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
    final appleSignInIsAvailable = await AppleSignIn.isAvailable();
    if (!appleSignInIsAvailable) {
      throw ('ご利用の端末では対応していません。');
    }

    final result = await AppleSignIn.performRequests([
      AppleIdRequest(
        requestedScopes: [Scope.email, Scope.fullName],
      ),
    ]);

    if (result.status == AuthorizationStatus.cancelled) {
      return print('cancel');
    }

    if (result.status == AuthorizationStatus.error) {
      return print('error');
    }

    if (result.status == AuthorizationStatus.authorized) {
      isLoading = true;
      notifyListeners();

      final AppleIdCredential appleIdCredential = result.credential;
      final oAuthProvider = auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken),
        accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
      );

      auth.User user = (await _auth.signInWithCredential(credential)).user;

      if (user == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      if (appleIdCredential.email != null) {
        await user.updateEmail(appleIdCredential.email);
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
                'displayName': getFullName(appleIdCredential),
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
  }

  Future signInWithFacebook() async {
    final result = await _facebookLogin.logIn(['email']);

    if (result.status == FacebookLoginStatus.cancelledByUser) {
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

  String getFullName(AppleIdCredential credential) {
    return '${credential.fullName.givenName} ${credential.fullName.familyName}';
  }

  Future<String> getDefaultPhotoURL() async {
    final path = '/images/default.jpg';
    final photoRef = _storage.ref().child(path);
    String photoURL = await photoRef.getDownloadURL();
    return photoURL;
  }
}
