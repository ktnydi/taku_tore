import 'package:flutter/material.dart';
import 'package:takutore/atoms/gradation_button.dart';
import 'package:takutore/presentation/login/login_page.dart';
import 'package:takutore/presentation/signup/signup_page.dart';

class LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ログインが必要です',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headline5.color,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'ログインすると、気になる講師を保存したり、メッセージで相談できるようになります。',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline4.color,
                  ),
                ),
                SizedBox(height: 20),
                GradationButton(
                  width: 150,
                  height: 44,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                    ],
                  ),
                  textColor: Colors.white,
                  child: Text(
                    'ログイン',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (BuildContext context) => Login(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          FlatButton(
            textColor: Theme.of(context).textTheme.headline5.color,
            child: Text(
              'アカウントを作成する',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (BuildContext context) => SignUp(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
