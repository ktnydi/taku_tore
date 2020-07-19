import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscureText = true;
  bool isLoading = false;
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
      _nameController,
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
                title: Text('メールアドレスで新規登録'),
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
                            controller: _nameController,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return '入力してください。';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'ユーザー名',
                            ),
                            onFieldSubmitted: (_) {
                              myFocusNode.nextFocus();
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            focusNode: myFocusNode,
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
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return '入力してください。';
                              }
                              return null;
                            },
                            obscureText: isObscureText,
                            decoration: InputDecoration(
                              hintText: 'パスワード',
                              suffixIcon: ButtonTheme(
                                minWidth: 0.0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.0,
                                ),
                                child: FlatButton(
                                  child: Text(
                                    isObscureText ? '表示' : '隠す',
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    setState(() {
                                      isObscureText = !isObscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) {
                              myFocusNode.unfocus();
                            },
                          ),
                          SizedBox(height: 30),
                          RoundedButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'アカウント作成',
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
                                await model.signUpWithEmail(
                                  name: _nameController.text,
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
