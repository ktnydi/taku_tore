import 'dart:io';
import 'dart:typed_data';
import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:takutore/config.dart';
import '../../domain/user.dart';

class SettingImageModel extends ChangeNotifier {
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
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

    final user = auth.FirebaseAuth.instance.currentUser;
    final document =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await document.get();
    this.currentUser = User(
      uid: doc.id,
      displayName: doc.data()['displayName'],
      photoURL: doc.data()['photoURL'],
      isTeacher: doc.data()['isTeacher'],
      createdAt: doc.data()['createdAt'],
      blockedUserID: doc.data()['blockedUserID'],
    );

    _isLoading = false;
    notifyListeners();
  }

  Future fetchImageFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    final File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
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

  Future<String> uploadImage() async {
    _isLoading = true;
    notifyListeners();

    // Firebase Storageに画像をアップロード
    final path = '/images/${this.currentUser.uid}.jpg';
    final Reference storageRef = FirebaseStorage.instance.ref().child(path);
    // 以下をを指定しないとiOSではcontentTypeがapplication/octet-streamになる。
    final metaData = SettableMetadata(contentType: "image/jpg");
    final uploadTask = storageRef.putData(
      this.imageData,
      metaData,
    );

    // 画像の保存完了時にFirebaseにURLを保存する。
    final snapshot = uploadTask.snapshot;
    String photoURL = await snapshot.ref.getDownloadURL();
    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.uid);
    final batch = FirebaseFirestore.instance.batch();

    batch.update(
      doc,
      {
        'photoURL': photoURL,
      },
    );

    if (this.currentUser.isTeacher) {
      batch.update(
        doc.collection('teachers').doc(this.currentUser.uid),
        {
          'photoURL': photoURL,
        },
      );
    }

    await batch.commit();

    if (this.currentUser.isTeacher) {
      await updateAlgoliaTeacher(
        {
          'photoURL': photoURL,
        },
      );
    }

    _isLoading = false;
    notifyListeners();
    return photoURL;
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
