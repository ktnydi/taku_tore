import 'package:flutter/material.dart';

class MainModel extends ChangeNotifier {
  bool isRequiredUpdate = false;

  Future<void> checkVersion() async {
    // TODO: check whether update is needed or not.
  }
}
