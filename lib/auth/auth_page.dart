import 'package:flutter/material.dart';
import '../login/login_page.dart';
import '../signup/signup_page.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}