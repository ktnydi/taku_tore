import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../common/loading.dart';
import 'remove_teacher_model.dart';

class RemoveTeacher extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Future removeTeacher(BuildContext context, RemoveTeacherModel model) async {
    if (_formKey.currentState.validate()) {
      try {
        final isRemoved = await confirmRemoved(context);
        if (!isRemoved) {
          return;
        }

        await model.removeAsTeacher();
        await _showDialog(
          context,
          titleText: '成功',
          contentText: '登録を解除しました。',
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        model.endLoading();
        await _showDialog(
          context,
          titleText: 'エラー',
          contentText: e.toString(),
        );
      }
    }
  }

  Future<bool> confirmRemoved(context) async {
    final isConfirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('講師登録を解除します'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                '解除',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return isConfirm;
  }

  Future _showDialog(context, {String titleText, String contentText}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RemoveTeacherModel>(
      create: (_) => RemoveTeacherModel(),
      child: Consumer<RemoveTeacherModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(),
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '講師登録の解除',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '講師に関連するデータは全て削除されます。',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 30),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      autofocus: true,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: 'パスワード',
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return '入力してください。';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) =>
                                          model.password = value,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 25),
                              RoundedButton(
                                disabledColor: Colors.white,
                                color: Colors.white,
                                child: Text(
                                  '講師を止める',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  await removeTeacher(context, model);
                                },
                              ),
                              SizedBox(height: 10),
                              RoundedButton(
                                child: Text(
                                  '閉じる',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Loading(model.isLoading),
            ],
          );
        },
      ),
    );
  }
}
