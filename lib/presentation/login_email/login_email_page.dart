import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/atoms/rounded_button.dart';
import 'package:takutore/presentation/forgot_password/forgot_password_page.dart';
import 'login_email_model.dart';

class LoginEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return ChangeNotifierProvider<LoginEmailModel>(
      create: (_) => LoginEmailModel(),
      child: Consumer<LoginEmailModel>(
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
                            controller: model.emailController,
                            textInputAction: TextInputAction.next,
                            autofocus: true,
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
                            focusNode: model.myFocusNode,
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
                              model.myFocusNode.unfocus();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ButtonTheme(
                              minWidth: 0,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  'パスワードをお忘れですか？',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ForgotPassword(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
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
                                model.myFocusNode.unfocus();
                                model.beginLoading();

                                await model.loginWithEmail();

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
                          SizedBox(height: 15),
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
