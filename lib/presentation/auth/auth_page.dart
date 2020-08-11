import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../common/loading.dart';
import '../../atoms/rounded_button.dart';
import '../signup/signup_page.dart';
import '../login/login_page.dart';
import 'auth_model.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      child: Consumer<AuthModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                resizeToAvoidBottomInset: false,
                body: Container(
                  padding: EdgeInsets.all(15.0),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          flex: 5,
                          child: AuthHeader(),
                        ),
                        Flexible(
                          flex: 3,
                          child: AuthButtonList(),
                        ),
                        AuthBottom(),
                      ],
                    ),
                  ),
                ),
              ),
              Loading(model.isLoading),
            ],
          );
        },
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Welcome back!'.toUpperCase(),
          style: TextStyle(
            fontSize: 16 + MediaQuery.of(context).size.height * 0.015,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: double.infinity,
          height: 160 + MediaQuery.of(context).size.height * 0.1,
          child: Image.asset(
            'images/fitness.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class AuthButtonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (_, model, __) {
        return Column(
          children: <Widget>[
            EmailLoginButton(),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: GoogleButton(model),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppleButton(model),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FacebookButton(model),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: <Widget>[
                Flexible(
                  child: Divider(height: 0.5),
                ),
                SizedBox(width: 5),
                Text(
                  'アカウントをお持ちでない場合',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: Divider(height: 0.5),
                ),
              ],
            ),
            SizedBox(height: 15),
            EmailRegisterButton(),
          ],
        );
      },
    );
  }
}

class EmailLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      color: Theme.of(context).primaryColor,
      child: Text(
        'メールアドレスでログイン',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return Login();
            },
            fullscreenDialog: true,
          ),
        );
      },
    );
  }
}

class EmailRegisterButton extends StatelessWidget {
  Future _alertDialog(BuildContext context, {String errorText}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorText),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text(
            '続けるには利用規約またはプライバシーポリシーに同意する必要があります。',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                '送信',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      side: BorderSide(color: Theme.of(context).primaryColor),
      child: Text(
        'メールアドレスで新規登録',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SignUp(),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }
}

class GoogleButton extends StatelessWidget {
  GoogleButton(this.model);

  final AuthModel model;
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      minWidth: MediaQuery.of(context).size.width / 4,
      child: Image.asset(
        'images/google.png',
        width: 25,
        height: 25,
      ),
      color: Colors.white,
      onPressed: () async {
        try {
          await model.signUpWithGoogle();
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}

class AppleButton extends StatelessWidget {
  AppleButton(this.model);

  final AuthModel model;
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      minWidth: MediaQuery.of(context).size.width / 4,
      child: Image.asset(
        'images/apple.png',
        width: 25,
        height: 25,
      ),
      color: Colors.black,
      onPressed: () async {
        try {
          await model.signInWithApple();
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}

class FacebookButton extends StatelessWidget {
  FacebookButton(this.model);

  final AuthModel model;
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      minWidth: MediaQuery.of(context).size.width / 4,
      child: Image.asset(
        'images/facebook.png',
        width: 25,
        height: 25,
      ),
      color: Color(0xFF1778f2),
      onPressed: () async {
        try {
          await model.signInWithFacebook();
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}

class AuthBottom extends StatelessWidget {
  Future _alertDialog(BuildContext context, {String errorText}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorText),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RichText(
        text: TextSpan(
          text: 'ログインすると',
          style: TextStyle(color: Colors.black54),
          children: <TextSpan>[
            TextSpan(
              text: '利用規約',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  try {
                    const url =
                        'https://takutore-e2ffa.firebaseapp.com/terms.html';
                    if (await launcher.canLaunch(url)) {
                      await launcher.launch(url);
                    } else {
                      throw '利用規約の読み込みに失敗しました。';
                    }
                  } catch (e) {
                    this._alertDialog(context, errorText: e.toString());
                  }
                },
            ),
            TextSpan(
              text: 'または',
            ),
            TextSpan(
              text: 'プライバシーポリシー',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  try {
                    const url =
                        'https://takutore-e2ffa.firebaseapp.com/privacy.html';
                    if (await launcher.canLaunch(url)) {
                      await launcher.launch(url);
                    } else {
                      throw 'プライバシーポリシーの読み込みに失敗しました。';
                    }
                  } catch (e) {
                    this._alertDialog(context, errorText: e.toString());
                  }
                },
            ),
            TextSpan(
              text: 'に同意したものとみなされます。',
            ),
          ],
        ),
      ),
    );
  }
}
