import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class SettingTeacherModel extends ChangeNotifier {
  File imageFile;
  Uint8List imageData;
  String _title = '';
  String _about = '';
  String _canDo = '';
  String _recommend = '';
  bool isLoading = false;

  String get title => this._title;
  String get about => this._about;
  String get canDo => this._canDo;
  String get recommend => this._recommend;

  set title(String value) {
    this._title = value;
    notifyListeners();
  }

  set about(String value) {
    this._about = value;
    notifyListeners();
  }

  set canDo(String value) {
    this._canDo = value;
    notifyListeners();
  }

  set recommend(String value) {
    this._recommend = value;
    notifyListeners();
  }

  bool disabled() {
    final fields = [this._title, this._about, this._canDo, this._recommend];
    final isComplete = fields.every((field) {
      return 0 < field.length && field.length <= 500;
    });
    return !isComplete;
  }

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future selectThumbnail() async {
    final PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    this.imageFile = File(pickedFile.path);
    this.imageData = await pickedFile.readAsBytes();

    notifyListeners();
  }

  Future registerAsTeacher() async {
    beginLoading();
    if (this.imageData == null) {
      throw ('サムネイルを選択してください');
    }

    final user = await FirebaseAuth.instance.currentUser();

    // Firebase Storageに画像をアップロード
    final path = '/images/${user.uid}_thumbnail.jpg';
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
    String thumbnail = await snapshot.ref.getDownloadURL();

    final doc = Firestore.instance.collection('users').document(user.uid);
    await doc.updateData({
      'thumbnail': thumbnail,
      'isTeacher': true,
      'title': this._title,
      'about': this._about,
      'canDo': this._canDo,
      'recommend': this._recommend,
      'avgRating': 0.0,
      'numRatings': 0.0,
    });
    endLoading();
  }
}
