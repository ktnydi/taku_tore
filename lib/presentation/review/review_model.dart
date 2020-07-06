import 'package:flutter/material.dart';

class ReviewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
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

  Future addReview() async {
    beginLoading();

    // TODO: save review to firebase
    await Future.delayed(Duration(milliseconds: 3000));

    if (this.rating < 1.0) {
      throw ('評価を決めてください。');
    }

    endLoading();
  }
}
