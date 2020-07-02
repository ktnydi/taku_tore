import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Stack(
          children: <Widget>[
            Scaffold(
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
                          ButtonTheme(
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
                              onPressed: () async {
                                try {
                                  await model.loginWithEmail(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  Navigator.pop(context);
                                } catch (error) {
                                  model.endLoading();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(error.toString()),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('OK'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Loading(model.isLoading),
          ],
        );
      },
    );
  }
}
