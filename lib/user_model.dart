import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:takutore/config.dart';
import 'domain/user.dart';

class UserModel extends ChangeNotifier {
  User user;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
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
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );
  }

  void checkUserSignIn() {
    auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final doc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        doc.snapshots().listen((snapshot) {
          final userData = snapshot.data();

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

  Future signOut() async {
    final deviceToken = await _firebaseMessaging.getToken();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tokens')
        .doc(deviceToken)
        .delete();

    await auth.FirebaseAuth.instance.signOut();
  }

  Future<bool> hasAvatar({auth.User user}) async {
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
    auth.User user = auth.FirebaseAuth.instance.currentUser;

    final result = await user.reauthenticateWithCredential(
      auth.EmailAuthProvider.credential(
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
    final userRef = _store.collection('users').doc(user.uid);
    final teacherRef = userRef.collection('teachers').doc(user.uid);
    final studentRoomRef = userRef.collection('rooms');
    final teacherRoomRef = teacherRef.collection('rooms');
    final bookmarkRef = userRef.collection('bookmarks');
    final reviewRef = teacherRef.collection('reviews');
    final noticeRef = userRef.collection('notices');

    // rooms, messagesのデータ削除
    await Future.forEach(
      [studentRoomRef, teacherRoomRef],
      (CollectionReference roomRef) async {
        final roomDocs = await roomRef.get();
        await Future.forEach(
          roomDocs.docs,
          (DocumentSnapshot doc) async {
            final msgRef = doc.reference.collection('messages');
            final msgDocs = await msgRef.get();

            await Future.forEach(
              msgDocs.docs,
              (DocumentSnapshot doc) async {
                await doc.reference.delete();
              },
            );

            await doc.reference.delete();
          },
        );
      },
    );

    // bookmarksのデータ削除
    final bookmarkDocs = await bookmarkRef.get();
    Future.forEach(
      bookmarkDocs.docs,
      (DocumentSnapshot doc) async {
        await bookmarkRef.doc(doc.id).delete();
      },
    );

    // reviewsのデータ削除
    final reviewDocs = await reviewRef.get();
    Future.forEach(
      reviewDocs.docs,
      (DocumentSnapshot doc) async {
        await reviewRef.doc(doc.id).delete();
      },
    );

    // noticesのデータ削除
    final noticeDocs = await noticeRef.get();
    Future.forEach(
      noticeDocs.docs,
      (DocumentSnapshot doc) async {
        await noticeRef.doc(doc.id).delete();
      },
    );

    final userDoc = await userRef.get();

    if (userDoc.data()['isTeacher']) {
      await FirebaseStorage.instance
          .ref()
          .child('/images/${user.uid}_thumbnail.jpg')
          .delete();
    }

    // tokenの削除
    final docs = await userRef.collection('tokens').get();
    await Future.forEach(
      docs.docs,
      (DocumentSnapshot doc) async {
        await doc.reference.delete();
      },
    );

    await teacherRef.delete();

    await _algolia.index('teacher').object(this.user.uid).deleteObject();

    // userのデータ削除
    await userRef.delete();

    await user.delete();
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

  Future updateName({@required String name}) async {
    beginLoading();

    if (name.length > 20) {
      throw ('名前が長すぎます。');
    }

    final doc =
        FirebaseFirestore.instance.collection('users').doc(this.user.uid);
    final batch = FirebaseFirestore.instance.batch();

    batch.update(
      doc,
      {
        'displayName': name,
      },
    );

    if (this.user.isTeacher) {
      batch.update(
        doc.collection('teachers').doc(this.user.uid),
        {
          'displayName': name,
        },
      );
    }

    await batch.commit();

    if (this.user.isTeacher) {
      print('update');
      await updateAlgoliaTeacher(
        {
          'displayName': name,
        },
      );
    }

    endLoading();
  }

  Future updateEmail({
    @required String email,
    @required String password,
  }) async {
    beginLoading();

    auth.User user = auth.FirebaseAuth.instance.currentUser;
    auth.UserCredential result = await user.reauthenticateWithCredential(
      auth.EmailAuthProvider.credential(
        email: user.email,
        password: password,
      ),
    );
    await result.user.updateEmail(email);
    await result.user.sendEmailVerification();

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

    auth.User user = auth.FirebaseAuth.instance.currentUser;
    auth.UserCredential result = await user.reauthenticateWithCredential(
      auth.EmailAuthProvider.credential(
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
    final doc =
        FirebaseFirestore.instance.collection('users').doc(this.user.uid);

    await doc.update({
      'isTeacher': true,
      'about': about,
      'canDo': canDo,
      'recommend': recommend,
    });
    endLoading();
  }

  Future removeAsTeacher({@required String password}) async {
    await confirmPassword(password);

    final doc =
        FirebaseFirestore.instance.collection('users').doc(this.user.uid);

    await doc.update({
      'isTeacher': false,
    });
  }

  Future updateAlgoliaTeacher(Map<String, dynamic> data) async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final teacher =
        await _algolia.index('teacher').object(currentUser.uid).getObject();

    final newTeacher = {
      ...teacher.data,
      ...data,
    };

    await _algolia
        .index('teacher')
        .object(currentUser.uid)
        .updateData(newTeacher);
  }
}
