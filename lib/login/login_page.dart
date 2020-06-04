import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    final List<TextEditingController> _controllers = [
      _emailController,
      _passwordController,
    ];
    _controllers.forEach((_controller) => _controller.dispose());
  }

  void login() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      // TODO: success
      try {
        AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (_result.user != null) {
          Navigator.pop(context);
        }
      } catch (error) {
        _authDialog(error.message);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
    // TODO: failure
  }

  Future<void> _authDialog(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            ButtonTheme(
              minWidth: 0,
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '閉じる',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'ログイン',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'メールアドレス',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'パスワード',
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: !isLoading
                        ? ButtonTheme(
                            minWidth: double.infinity,
                            height: 50,
                            textTheme: ButtonTextTheme.primary,
                            child: RaisedButton(
                              child: Text(
                                'ログイン',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: login,
                            ),
                          )
                        : CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
