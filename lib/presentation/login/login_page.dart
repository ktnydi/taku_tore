import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
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
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    final List<TextEditingController> _controllers = [
      _emailController,
      _passwordController,
    ];
    _controllers.forEach((_controller) => _controller.dispose());
    myFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                title: Text('メールアドレスでログイン'),
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: SafeArea(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return '入力してください。';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'メールアドレス',
                            ),
                            onFieldSubmitted: (_) {
                              myFocusNode.nextFocus();
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: myFocusNode,
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
                            onFieldSubmitted: (_) {
                              myFocusNode.unfocus();
                            },
                          ),
                          SizedBox(height: 30),
                          RoundedButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'ログイン',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState.validate()) {
                                return;
                              }

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
