import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'domain/user.dart';

class UserModel extends ChangeNotifier {
  User user;
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
      await Firestore.instance.document('users/${result.user.uid}').setData({
        'displayName': name,
        'photoURL': photoURL,
        'isTeacher': false,
        'deviceToken': deviceToken,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    endLoading();
  }

  Future loginWithEmail({
    @required String email,
    @required String password,
  }) async {
    beginLoading();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    endLoading();
  }

  Future signOut() async {
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

  Future removeUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      if (await hasAvatar(user: user)) {
        await FirebaseStorage.instance
            .ref()
            .child('/images/${user.uid}.jpg')
            .delete();
      }
      await Firestore.instance.document('/users/${user.uid}').delete();
      await user.delete();
    }
  }

  Future<String> uploadImage() async {
    final PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    beginLoading();

    final imageData = await pickedFile.readAsBytes();

    // Firebase Storageに画像をアップロード
    final path = '/images/${this.user.uid}.jpg';
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(path);
    // 以下をを指定しないとiOSではcontentTypeがapplication/octet-streamになる。
    final metaData = StorageMetadata(contentType: "image/jpg");
    final StorageUploadTask uploadTask = storageRef.putData(
      imageData,
      metaData,
    );

    // 画像の保存完了時にFirebaseにURLを保存する。
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String photoURL = await snapshot.ref.getDownloadURL();
    final doc = Firestore.instance.collection('users').document(this.user.uid);
    await doc.updateData({
      'photoURL': photoURL,
    });

    endLoading();
    return photoURL;
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
