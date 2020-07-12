import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../../user_model.dart';

class RemoveUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            SizedBox(height: 30),
            Consumer<UserModel>(builder: (_, model, __) {
              return RoundedButton(
                textColor: Colors.redAccent,
                color: Colors.white,
                child: Text(
                  'アカウントを削除する',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // TODO: Implement processing for removing account.
                  try {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('本当に削除しますか？'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('キャンセル'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text(
                                '削除する',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                              onPressed: () async {
                                await model.removeUser();
                                // Dialogを閉じる。
                                Navigator.pop(context);
                                // 前のスクリーンに戻る。
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(error.toString()),
                          actions: <Widget>[
                            FlatButton(
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
              );
            }),
          ],
        ),
      ),
    );
  }
}
