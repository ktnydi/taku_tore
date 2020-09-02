import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final webAppURL = DotEnv().env['GOOGLE_WEB_APP_FEEDBACK_URL'];

    await http.post(
      webAppURL,
      body: {
        'senderID': currentUser.uid,
        'content': content,
        'createdAt': DateTime.now().toString(),
      },
    );
  }
}
