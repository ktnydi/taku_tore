import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';

class ReviewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  User _teacher;
  double _rating = 0;
  String _comment = '';
  bool isLoading = false;

  void beginLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  double get rating => this._rating;
  String get comment => this._comment;

  set rating(double value) {
    this._rating = value;
    notifyListeners();
  }

  set comment(String value) {
    this._comment = value;
    notifyListeners();
  }

  set teacher(User user) {
    this._teacher = user;
  }

  Future addReview() async {
    beginLoading();

    if (this.rating < 1.0) {
      throw ('評価を決めてください。');
    }

    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(this._teacher.uid)
        .collection('reviews');

    await collection.add({
      'rating': this._rating,
      'comment': this._comment,
      'fromUid': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    endLoading();
  }
}