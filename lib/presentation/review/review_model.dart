import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takutore/config.dart';
import 'package:takutore/domain/teacher.dart';

class ReviewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final _algolia = Algolia.init(
    applicationId: Config.algoliaApplicationId,
    apiKey: Config.algoliaApiKey,
  );
  Teacher _teacher;
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

  set teacher(Teacher user) {
    this._teacher = user;
  }

  Future addReview() async {
    beginLoading();

    if (this.rating < 1.0) {
      throw ('評価を決めてください。');
    }

    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final teacherRef = FirebaseFirestore.instance
        .collection('users')
        .doc(this._teacher.uid)
        .collection('teachers')
        .doc(this._teacher.uid);

    final reviewRef = teacherRef.collection('reviews').doc();

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        final doc = await transaction.get(teacherRef);

        if (!doc.exists) {
          return;
        }

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

    final double avgRating = this._teacher.avgRating;
    final int numRatings = this._teacher.numRatings;
    final double sumRating = avgRating * numRatings;
    final double newSumRating = sumRating + this._rating;
    final int newNumRatings = numRatings + 1;
    final double newAvgRating = (newSumRating / newNumRatings).toDouble();

    this.updateAlgoliaTeacher(
      {
        'avgRating': newAvgRating,
        'numRatings': newNumRatings,
      },
    );

    endLoading();
  }

  Future updateAlgoliaTeacher(Map<String, dynamic> data) async {
    final teacher =
        await _algolia.index('teacher').object(this._teacher.uid).getObject();

    final newTeacher = {
      ...teacher.data,
      ...data,
    };

    await _algolia
        .index('teacher')
        .object(this._teacher.uid)
        .updateData(newTeacher);
  }
}
