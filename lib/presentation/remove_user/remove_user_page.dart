import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../../user_model.dart';

class RemoveUser extends StatelessWidget {
  Future<bool> _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('アカウントを削除'),
          content: Text('アカウントを削除します。本当に削除してよろしいですか？'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                '削除',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String password = '';

    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                title: Text(
                  'アカウント削除',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '注意',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'アカウントを削除するとTakuToreに関するデータは全て削除され、二度と元に戻せなくなります。',
                    ),
                    SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return '入力してください';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'パスワード',
                        ),
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    RoundedButton(
                      textColor: Colors.redAccent,
                      color: Colors.white,
                      child: Text(
                        'アカウントを削除する',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }

                        try {
                          final confirm = await this._confirmDialog(context);

                          if (!confirm) return;

                          model.beginLoading();

                          await model.removeUser(password: password);

                          model.endLoading();

                          Navigator.pop(context);
                        } catch (error) {
                          model.endLoading();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(error.toString()),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
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
            model.isLoading
                ? Container(
                    color: Colors.white.withOpacity(0.6),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }
}
