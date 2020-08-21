import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              padding: EdgeInsets.all(15.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: AuthHeader(),
                    ),
                    AuthButtonList(),
                  ],
                ),
              ),
            ),
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
        'ログイン',
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
  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      child: Text(
        '新規登録',
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
