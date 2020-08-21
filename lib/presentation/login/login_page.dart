import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/auth/auth_model.dart';
import 'package:takutore/presentation/login_email/login_email_page.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../atoms/rounded_button.dart';

class Login extends StatelessWidget {
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
    return ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      child: Consumer<AuthModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text('ログイン'),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: SafeArea(
                      child: Column(
                        children: <Widget>[
                          EmailButton(),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Divider(height: 0.5),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'SNSアカウントでログイン',
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
                          SizedBox(height: 10),
                          AuthButtonList(),
                          SizedBox(height: 10),
                          Container(
                            child: RichText(
                              text: TextSpan(
                                text: 'ログインすると',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
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
                                          this._alertDialog(context,
                                              errorText: e.toString());
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
                                          this._alertDialog(context,
                                              errorText: e.toString());
                                        }
                                      },
                                  ),
                                  TextSpan(
                                    text: 'に同意したものとみなされます。',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              model.isLoading
                  ? Container(
                      color: Colors.white.withOpacity(0.7),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
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
            Column(
              children: <Widget>[
                GoogleButton(model),
                SizedBox(height: 10),
                AppleButton(model),
                SizedBox(height: 10),
                FacebookButton(model),
              ],
            ),
          ],
        );
      },
    );
  }
}

class EmailButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      child: Text(
        'メールアドレスでログイン',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      color: Colors.red,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginEmail(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            'images/google.png',
            width: 25,
            height: 25,
          ),
          Text(
            'Googleでログイン',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 25),
        ],
      ),
      color: Colors.white,
      onPressed: () async {
        try {
          await model.signUpWithGoogle();
          Navigator.pop(context);
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            'images/apple.png',
            width: 25,
            height: 25,
          ),
          Text(
            'Appleでログイン',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 25),
        ],
      ),
      color: Colors.black,
      onPressed: () async {
        try {
          await model.signInWithApple();
          Navigator.pop(context);
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset(
            'images/facebook.png',
            width: 25,
            height: 25,
          ),
          Text(
            'Facebookでログイン',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 25),
        ],
      ),
      color: Color(0xFF1778f2),
      onPressed: () async {
        try {
          await model.signInWithFacebook();
          Navigator.pop(context);
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}
