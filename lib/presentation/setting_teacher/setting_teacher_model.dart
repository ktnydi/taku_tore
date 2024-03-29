import 'dart:io';
import 'dart:typed_data';
import 'package:algolia/algolia.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:takutore/config.dart';

class SettingTeacherModel extends ChangeNotifier {
  final _store = FirebaseFirestore.instance;
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    final File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
        cancelButtonTitle: 'キャンセル',
        doneButtonTitle: '完了',
      ),
    );

    if (croppedFile == null) {
      return;
    }

    this.imageFile = croppedFile;
    this.imageData = await croppedFile.readAsBytes();

    notifyListeners();
  }

  Future registerAsTeacher() async {
    if (this.imageData == null) {
      throw ('サムネイルを選択してください');
    }

    final user = auth.FirebaseAuth.instance.currentUser;

    // Firebase Storageに画像をアップロード
    final path = '/images/${user.uid}_thumbnail.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(path);

    // 以下をを指定しないとiOSではcontentTypeがapplication/octet-streamになる。
    final metaData = SettableMetadata(contentType: "image/jpg");
    final uploadTask = storageRef.putData(
      this.imageData,
      metaData,
    );

    // 画像の保存完了時にFirebaseにURLを保存する。
    final snapshot = uploadTask.snapshot;
    String thumbnail = await snapshot.ref.getDownloadURL();

    final userSnapshot = await _store.collection('users').doc(user.uid).get();
    final teacherRef =
        userSnapshot.reference.collection('teachers').doc(userSnapshot.id);

    final batch = _store.batch();

    batch.update(
      userSnapshot.reference,
      {
        'isTeacher': true,
      },
    );

    Map<String, dynamic> newTeacher = {
      'userID': userSnapshot.id,
      'displayName': userSnapshot.data()['displayName'],
      'photoURL': userSnapshot.data()['photoURL'],
      'blockedUserID': userSnapshot.data()['blockedUserID'],
      'isTeacher': true,
      'thumbnail': thumbnail,
      'title': this._title,
      'about': this._about,
      'canDo': this._canDo,
      'recommend': this._recommend,
      'avgRating': 0.0,
      'numRatings': 0,
      'isRecruiting': true,
    };

    batch.set(
      teacherRef,
      newTeacher,
    );

    await batch.commit();

    await _algolia.index('teacher').addObject(
      {
        'objectID': userSnapshot.id,
        ...newTeacher,
      },
    );
  }
}
