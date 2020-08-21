import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/atoms/rounded_button.dart';
import 'signup_email_model.dart';

class SignUpEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return ChangeNotifierProvider<SignUpEmailModel>(
      create: (_) => SignUpEmailModel(),
      child: Consumer<SignUpEmailModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text('メールアドレス'),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: model.nameController,
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
                              model.myFocusNode.nextFocus();
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: model.emailController,
                            focusNode: model.myFocusNode,
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
                              model.myFocusNode.nextFocus();
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: model.passwordController,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return '入力してください。';
                              }
                              return null;
                            },
                            obscureText: model.isObscureText,
                            decoration: InputDecoration(
                              hintText: 'パスワード',
                              suffixIcon: ButtonTheme(
                                minWidth: 0.0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.0,
                                ),
                                child: FlatButton(
                                  child: Text(
                                    model.isObscureText ? '表示' : '隠す',
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    model.toggleObscureText();
                                  },
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) {
                              model.myFocusNode.unfocus();
                            },
                          ),
                          SizedBox(height: 15),
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
                                model.myFocusNode.unfocus();
                                model.beginLoading();

                                await model.signUpWithEmail();

                                model.endLoading();

                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
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
