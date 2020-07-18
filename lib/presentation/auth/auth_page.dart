import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/loading.dart';
import '../../atoms/rounded_button.dart';
import '../signup/signup_page.dart';
import '../login/login_page.dart';
import 'auth_model.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      child: Consumer<AuthModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                body: Container(
                  padding: EdgeInsets.all(16.0),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'TakuTore',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 80),
                        ButtonTheme(
                          minWidth: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            child: Text(
                              'ログイン',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Implement navigator to login page.
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
                          ),
                        ),
                        SizedBox(height: 15),
                        RoundedButton(
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(width: 25),
                            ],
                          ),
                          color: Colors.white,
                          onPressed: () async {
                            try {
                              await model.signUpWithGoogle();
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                        ),
                        SizedBox(height: 15),
                        RoundedButton(
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(width: 25),
                            ],
                          ),
                          color: Colors.black,
                          onPressed: () async {
                            try {
                              await model.signInWithApple();
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                        ),
                        SizedBox(height: 40),
                        ButtonTheme(
                          textTheme: ButtonTextTheme.primary,
                          child: FlatButton(
                            child: Text(
                              'アカウント作成',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Implement navigator to register page.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => SignUp(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),
                        ),
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
