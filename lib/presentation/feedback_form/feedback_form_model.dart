import 'package:flutter/material.dart';

class FeedbackFormModel extends ChangeNotifier {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future addFeedback({String content}) async {
    // TODO: firestoreに保存し、functionsでSlackに通知する。
  }
}
