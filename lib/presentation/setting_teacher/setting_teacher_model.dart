import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingTeacherModel extends ChangeNotifier {
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

  Future registerAsTeacher() async {
    beginLoading();
    final user = await FirebaseAuth.instance.currentUser();
    final doc = Firestore.instance.collection('users').document(user.uid);

    await doc.updateData({
      'isTeacher': true,
      'title': this._title,
      'about': this._about,
      'canDo': this._canDo,
      'recommend': this._recommend,
    });
    endLoading();
  }
}
