import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takutore/config/application.dart';
import 'package:takutore/domain/teacher.dart';

class TeacherEditFormModel extends ChangeNotifier {
  final _auth = auth.FirebaseAuth.instance;
  final _algolia = Application.algolia.instance;
  Teacher teacher;
  String thumbnail;
  TextEditingController title;
  TextEditingController about;
  TextEditingController canDo;
  TextEditingController recommend;
  File imageFile;
  Uint8List imageData;
  bool isLoading = false;

  TeacherEditFormModel(Teacher teacher) {
    this.teacher = teacher;
    this.thumbnail = teacher.thumbnail;
    this.title = TextEditingController(text: teacher.title);
    this.about = TextEditingController(text: teacher.about);
    this.canDo = TextEditingController(text: teacher.canDo);
    this.recommend = TextEditingController(text: teacher.recommend);
  }

  void dispose() {
    super.dispose();

    final controllers = [this.title, this.about, this.canDo, this.recommend];
    controllers.forEach(
      (controller) => controller.dispose(),
    );
  }

  beginLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  bool disabled() {
    final fields = [this.title, this.about, this.canDo, this.recommend];
    final isComplete = fields.every((TextEditingController field) {
      return 0 < field.text.length && field.text.length <= 500;
    });
    return !isComplete;
  }

  Future selectThumbnail() async {
    final PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
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

  Future updateTeacher() async {
    final user = auth.FirebaseAuth.instance.currentUser;

    if (imageData != null) {
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
      this.thumbnail = await snapshot.ref.getDownloadURL();
    }

    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('teachers')
        .doc(user.uid);
    await doc.update({
      'thumbnail': this.thumbnail,
      'title': this.title.text,
      'canDo': this.canDo.text,
      'recommend': this.recommend.text,
      'about': this.about.text,
    });

    await updateAlgoliaTeacher(
      {
        'thumbnail': this.thumbnail,
        'title': this.title.text,
        'canDo': this.canDo.text,
        'recommend': this.recommend.text,
        'about': this.about.text,
      },
    );
  }

  Future updateAlgoliaTeacher(Map<String, dynamic> data) async {
    final currentUser = _auth.currentUser;

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
