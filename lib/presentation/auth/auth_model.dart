import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _store = Firestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseMessaging _messaging = FirebaseMessaging();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FacebookLogin _facebookLogin = FacebookLogin();
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
    // TODO: result.status を見てエラーハンドリング

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
      const oAuthProvider = OAuthProvider(providerId: 'apple.com');
      final credential = oAuthProvider.getCredential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken),
        accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
      );

      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      if (appleIdCredential.email != null) {
        await user.updateEmail(appleIdCredential.email);
      }

      bool registered = await hasAlreadyRegistered(userID: user.uid);

      if (user != null && !registered) {
        final deviceToken = await _messaging.getToken();
        await _store.collection('users').document(user.uid).setData(
          {
            'displayName': getFullName(appleIdCredential),
            'photoURL': await getDefaultPhotoURL(),
            'isTeacher': false,
            'deviceToken': deviceToken,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }

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

    final credential = FacebookAuthProvider.getCredential(
      accessToken: result.accessToken.token,
    );

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    bool registered = await hasAlreadyRegistered(userID: user.uid);

    if (user != null && !registered) {
      final deviceToken = await _messaging.getToken();
      await user.updateEmail(user.email);
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

  String getFullName(AppleIdCredential credential) {
    return '${credential.fullName.givenName} ${credential.fullName.familyName}';
  }

  Future<String> getDefaultPhotoURL() async {
    final path = '/images/default.jpg';
    final photoRef = _storage.ref().child(path);
    String photoURL = await photoRef.getDownloadURL();
    return photoURL;
  }

  Future<bool> hasAlreadyRegistered({String userID}) async {
    final user = _store.collection('users').document(userID);
    final doc = await user.get();
    return doc.exists;
  }
}
