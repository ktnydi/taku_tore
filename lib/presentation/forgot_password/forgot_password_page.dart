import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'forgot_password_model.dart';

class ForgotPassword extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Future _submit(BuildContext context, ForgotPasswordModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      model.beginLoading();

      await model.sendPasswordResetEmail();

      model.endLoading();

      await model.showMessage();
    } catch (e) {
      model.endLoading();
      await _showDialog(context, e.toString());
    }
  }

  Future _showDialog(BuildContext context, String errorText) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorText),
          actions: <Widget>[
            TextButton(
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

  Widget _buildLoading(ForgotPasswordModel model) {
    if (!model.isLoading) {
      return SizedBox();
    }

    return Container(
      color: Colors.white.withOpacity(0.6),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ForgotPasswordModel model) {
    final deviceSize = MediaQuery.of(context).size;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: model.isSendMail ? 1 : 0,
      child: Container(
        width: deviceSize.width,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0xff203152),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'パスワード再設定メールを送信しました',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordModel>(
      create: (_) => ForgotPasswordModel(),
      child: Consumer<ForgotPasswordModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('パスワード再設定'),
                    actions: <Widget>[
                      ButtonTheme(
                        minWidth: 0,
                        child: TextButton(
                          child: Text(
                            '送信',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            await _submit(context, model);
                          },
                        ),
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'ご登録いただいたメールアドレスを入力すると、パスワード変更ページが記載されたメールを送信します。',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 10),
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: model.email,
                                  autofocus: true,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value.trim().isEmpty) {
                                      return '入力してください。';
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'メールアドレス',
                                  ),
                                  onFieldSubmitted: (_) async {
                                    await _submit(context, model);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildMessage(context, model),
                      ],
                    ),
                  ),
                ),
              ),
              _buildLoading(model),
            ],
          );
        },
      ),
    );
  }
}
