import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'feedback_form_model.dart';

class FeedbackForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('フィードバックを送信しますか？'),
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
                '送信',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  Future _alertDialog(BuildContext context, {String errorText}) async {
    showDialog(
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

  Future _addFeedback(BuildContext context, {FeedbackFormModel model}) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    try {
      FocusScope.of(context).unfocus();

      final isConfirm = await this._confirmDialog(context);

      if (!isConfirm) return;

      model.beginLoading();

      await model.addFeedback(content: model.controller.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('フィードバックを送信しました'),
        ),
      );

      model.controller.clear();

      model.endLoading();
    } catch (e) {
      model.endLoading();
      this._alertDialog(
        context,
        errorText: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedbackFormModel>(
      create: (_) => FeedbackFormModel(),
      child: Consumer<FeedbackFormModel>(
        builder: (_, model, __) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: <Widget>[
                Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    title: Text('フィードバック'),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          '送信',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          await _addFeedback(context, model: model);
                        },
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Form(
                        key: _formKey,
                        child: FormField<String>(
                          initialValue: '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '入力してください';
                            }

                            if (value.length > 800) {
                              return '文字数が超過しています';
                            }

                            return null;
                          },
                          builder: (state) {
                            return Column(
                              children: <Widget>[
                                TextField(
                                  controller: model.controller,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: '内容を入力',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: state.hasError
                                            ? Colors.red
                                            : Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                  minLines: 1,
                                  maxLines: null,
                                  style: TextStyle(
                                    height: 1.5,
                                  ),
                                  onChanged: (value) {
                                    state.didChange(value);
                                  },
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        state.errorText ?? '',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Text('${state.value.length}/800'),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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
            ),
          );
        },
      ),
    );
  }
}
