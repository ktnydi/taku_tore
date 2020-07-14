import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/user.dart';

class SettingImageModel extends ChangeNotifier {
  User currentUser;
  File imageFile;
  Uint8List imageData;
  bool _isLoading = true;

  bool get isLoading => this._isLoading;

  set isLoading(bool isLoading) {
    this._isLoading = isLoading;
    notifyListeners();
  }

  Future fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final user = await FirebaseAuth.instance.currentUser();
    final document = Firestore.instance.collection('users').document(user.uid);
    final doc = await document.get();
    this.currentUser = User(
      uid: doc.documentID,
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      isTeacher: doc['isTeacher'],
      createdAt: doc['createdAt'],
    );

    _isLoading = false;
    notifyListeners();
  }

  Future fetchImageFile() async {
    final PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    this.imageFile = File(pickedFile.path);
    this.imageData = await pickedFile.readAsBytes();
    notifyListeners();
  }

  Future<String> uploadImage() async {
    _isLoading = true;
    notifyListeners();

    // Firebase Storageに画像をアップロード
    final path = '/images/${this.currentUser.uid}.jpg';
    final StorageReference storageRef =
        FirebaseStorage.instance.ref().child(path);
    // 以下をを指定しないとiOSではcontentTypeがapplication/octet-streamになる。
    final metaData = StorageMetadata(contentType: "image/jpg");
    final StorageUploadTask uploadTask = storageRef.putData(
      this.imageData,
      metaData,
    );

    // 画像の保存完了時にFirebaseにURLを保存する。
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String photoURL = await snapshot.ref.getDownloadURL();
    final doc =
        Firestore.instance.collection('users').document(this.currentUser.uid);
    await doc.updateData({
      'photoURL': photoURL,
    });

    _isLoading = false;
    notifyListeners();
    return photoURL;
  }
}
