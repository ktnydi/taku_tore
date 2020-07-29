import 'package:flutter/material.dart';

class NoticeListModel extends ChangeNotifier {
  bool isLoading = false;

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future fetchNotices() async {
    this.beginLoading();

    // Following code is dummy.
    // Actually, You write code for fetching notices here.
    await Future.delayed(
      Duration(milliseconds: 1000),
    );

    this.endLoading();
  }
}
