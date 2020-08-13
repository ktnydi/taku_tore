import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'domain/user.dart';

class UserModel extends ChangeNotifier {
  User user;
  final Firestore _store = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isLoading = false;

  void beginLoading() async {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() async {
    isLoading = false;
    notifyListeners();
  }

  Future confirmNotification() async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      ),
    );

    _firebaseMessaging.onIosSettingsRegistered.listen(
      (IosNotificationSettings settings) {
        print("Settings registered: $settings");
      },
    );

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void checkUserSignIn() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if (user != null) {
        final doc = Firestore.instance.collection('users').document(user.uid);
        doc.snapshots().listen((snapshot) {
          final userData = snapshot.data;

          if (userData != null) {
            this.user = User(
              uid: user.uid,
              email: user.email,
              displayName: userData['displayName'],
              photoURL: userData['photoURL'],
              isTeacher: userData['isTeacher'],
              blockedUserID: userData['blockedUserID'],
              createdAt: userData['createdAt'],
            );
          } else {
            this.user = null;
          }

          notifyListeners();
        });
      } else {
        this.user = null;

        notifyListeners();
      }
    });
  }

  Future signUpWithEmail({
    @required String name,
    @required String email,
    @required String password,
  }) async {
    beginLoading();
    if (name.length > 20) {
      throw ('名前が長すぎます。');
    }

    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      final path = '/images/default.jpg';
      final photoRef = FirebaseStorage.instance.ref().child(path);
      String photoURL = await photoRef.getDownloadURL();
      final deviceToken = await _firebaseMessaging.getToken();

      await Firestore.instance.runTransaction(
        (transaction) async {
          await transaction.set(
            Firestore.instance.collection('users').document(result.user.uid),
            {
              'displayName': name,
              'photoURL': photoURL,
              'isTeacher': false,
              'blockedUserID': [],
              'createdAt': FieldValue.serverTimestamp(),
            },
          );

          if (deviceToken != null || deviceToken.isNotEmpty) {
            await transaction.set(
              Firestore.instance
                  .collection('users')
                  .document(result.user.uid)
                  .collection('tokens')
                  .document(deviceToken),
              {
                'deviceToken': deviceToken,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );
          }
        },
      );
    }
    endLoading();
  }

  Future loginWithEmail({
    @required String email,
    @required String password,
  }) async {
    beginLoading();
    final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    if (user == null) {
      endLoading();
      return;
    }

    final deviceToken = await _firebaseMessaging.getToken();

    if (deviceToken != null && deviceToken.isNotEmpty) {
      final document = Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('tokens')
          .document(deviceToken);
      await document.setData(
        {
          'deviceToken': deviceToken,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    }

    endLoading();
  }

  Future signOut() async {
    final deviceToken = await _firebaseMessaging.getToken();

    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('tokens')
        .document(deviceToken)
        .delete();

    await FirebaseAuth.instance.signOut();
  }

  Future<bool> hasAvatar({FirebaseUser user}) async {
    try {
      await FirebaseStorage.instance
          .ref()
          .child('/images/${user.uid}.jpg')
          .getDownloadURL();
      return true;
    } catch (error) {
      return false;
    }
  }

  Future removeUser({String password}) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    final result = await user.reauthenticateWithCredential(
      EmailAuthProvider.getCredential(
        email: user.email,
        password: password,
      ),
    );

    if (result.user == null) return;

    if (await hasAvatar(user: user)) {
      await FirebaseStorage.instance
          .ref()
          .child('/images/${user.uid}.jpg')
          .delete();
    }
    final userRef = _store.collection('users').document(user.uid);
    final roomRef = userRef.collection('rooms');
    final bookmarkRef = userRef.collection('bookmarks');
    final reviewRef = userRef.collection('reviews');
    final noticeRef = userRef.collection('notices');

    // rooms, messagesのデータ削除
    final roomDocs = await roomRef.getDocuments();
    await Future.forEach(
      roomDocs.documents,
      (DocumentSnapshot doc) async {
        final msgRef = roomRef.document(doc.documentID).collection('messages');
        final msgDocs = await msgRef.getDocuments();

        await Future.forEach(
          msgDocs.documents,
          (DocumentSnapshot doc) async {
            await msgRef.document(doc.documentID).delete();
          },
        );

        await roomRef.document(doc.documentID).delete();
      },
    );

    // bookmarksのデータ削除
    final bookmarkDocs = await bookmarkRef.getDocuments();
    Future.forEach(
      bookmarkDocs.documents,
      (DocumentSnapshot doc) async {
        await bookmarkRef.document(doc.documentID).delete();
      },
    );

    // reviewsのデータ削除
    final reviewDocs = await reviewRef.getDocuments();
    Future.forEach(
      reviewDocs.documents,
      (DocumentSnapshot doc) async {
        await reviewRef.document(doc.documentID).delete();
      },
    );

    // noticesのデータ削除
    final noticeDocs = await noticeRef.getDocuments();
    Future.forEach(
      noticeDocs.documents,
      (DocumentSnapshot doc) async {
        await noticeRef.document(doc.documentID).delete();
      },
    );

    final userDoc = await userRef.get();

    if (userDoc['isTeacher']) {
      await FirebaseStorage.instance
          .ref()
          .child('/images/${user.uid}_thumbnail.jpg')
          .delete();
    }

    // tokenの削除
    final docs = await userRef.collection('tokens').getDocuments();
    await Future.forEach(
      docs.documents,
      (DocumentSnapshot doc) async {
        await doc.reference.delete();
      },
    );

    // userのデータ削除
    await userRef.delete();

    await user.delete();
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

  Future updateName({@required String name}) async {
    beginLoading();

    if (name.length > 20) {
      throw ('名前が長すぎます。');
    }

    final doc = Firestore.instance.collection('users').document(this.user.uid);
    await doc.updateData({
      'displayName': name,
    });

    endLoading();
  }

  Future updateEmail({
    @required String email,
    @required String password,
  }) async {
    beginLoading();

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    AuthResult result = await user.reauthenticateWithCredential(
      EmailAuthProvider.getCredential(
        email: user.email,
        password: password,
      ),
    );
    await result.user.updateEmail(email);

    endLoading();
  }

  Future updatePassword({
    @required String currentPassword,
    @required String newPassword,
    @required String newPasswordConfirm,
  }) async {
    beginLoading();

    if (newPassword != newPasswordConfirm) {
      throw ('新しいパスワードを一致させてください。');
    }

    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    AuthResult result = await user.reauthenticateWithCredential(
      EmailAuthProvider.getCredential(
        email: user.email,
        password: currentPassword,
      ),
    );

    await result.user.updatePassword(newPassword);
    endLoading();
  }

  Future registerAsTeacher({
    @required String about,
    @required String canDo,
    @required String recommend,
  }) async {
    beginLoading();
    final doc = Firestore.instance.collection('users').document(this.user.uid);

    await doc.updateData({
      'isTeacher': true,
      'about': about,
      'canDo': canDo,
      'recommend': recommend,
    });
    endLoading();
  }

  Future removeAsTeacher({@required String password}) async {
    await confirmPassword(password);

    final doc = Firestore.instance.collection('users').document(this.user.uid);

    await doc.updateData({
      'isTeacher': false,
    });
  }
}
