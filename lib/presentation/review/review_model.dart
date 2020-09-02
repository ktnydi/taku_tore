import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
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

    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(this._teacher.uid);

    final reviewRef = userRef.collection('reviews').doc();

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        final doc = await transaction.get(userRef);

        if (!doc.exists) {
          return;
        }

        final double oldNumRatings = doc.data()['numRatings'];
        final double oldAvgRating = doc.data()['avgRating'].toDouble();

        final double newNumRatings = oldNumRatings + 1;
        final double oldRatingTotal = oldAvgRating * oldNumRatings;
        final double newRatingTotal = oldRatingTotal + this._rating;
        final double newAvgRating = newRatingTotal / newNumRatings;

        transaction.update(
          userRef,
          {
            'avgRating': (newAvgRating * 10.0).floor() / 10.0,
            'numRatings': newNumRatings,
          },
        );

        transaction.set(
          reviewRef,
          {
            'teacherID': this._teacher.uid,
            'rating': this._rating,
            'comment': this._comment,
            'fromUid': currentUser.uid,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      },
    );

    endLoading();
  }
}
