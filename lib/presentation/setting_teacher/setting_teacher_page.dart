import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/teacher_form_confirm/teacher_form_confirm_page.dart';
import 'setting_teacher_model.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class SettingTeacher extends StatefulWidget {
  @override
  _SettingTeacherState createState() => _SettingTeacherState();
}

class _SettingTeacherState extends State<SettingTeacher> {
  bool isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future confirmPassword(UserModel model) async {
    try {
      if (_formKey.currentState.validate()) {
        setState(() => isLoading = true);
        await model.confirmPassword(_passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => BecomeTeacher(),
          ),
        );
      }
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (_, model, __) {
      return Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text(
                '講師になる',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    '次へ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () async {
                    await confirmPassword(model);
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('続けるには現在のパスワードを入力してください。'),
                    SizedBox(height: 20),
                    Text(
                      'パスワード',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofocus: true,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return '入力してください';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Loading(model.isLoading),
        ],
      );
    });
  }
}

class BecomeTeacher extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Future registerAsTeacher(context, SettingTeacherModel model) async {
    try {
      if (_formKey.currentState.validate()) {
        await model.registerAsTeacher();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('講師に登録しました。'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
        Navigator.pop(context);
      }
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingTeacherModel>(
      create: (_) => SettingTeacherModel(),
      child: Consumer<SettingTeacherModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text(
                    '講師に登録',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Thumbnail(),
                                SizedBox(height: 20),
                                Title(),
                                SizedBox(height: 20),
                                CanDo(),
                                SizedBox(height: 20),
                                Recommend(),
                                SizedBox(height: 20),
                                About(),
                                SizedBox(height: 20),
                                ButtonTheme(
                                  minWidth: double.infinity,
                                  height: 50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: FlatButton(
                                    color: Theme.of(context).primaryColor,
                                    child: Text(
                                      '入力した内容を確認する',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    disabledColor: Colors.black38,
                                    onPressed: !model.disabled()
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        TeacherFormConfirm(
                                                            model: model),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
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

class Thumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'サービスサムネイル',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Consumer<SettingTeacherModel>(
          builder: (_, model, __) {
            return InkWell(
              onTap: () async {
                // TODO: select thumbnail image
                await model.selectThumbnail();
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                  ),
                  child: model.imageFile != null
                      ? Image.file(
                          model.imageFile,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.black38,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'タップして画像を選択',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingTeacherModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'サービスタイトル',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 80) {
                  return '80文字以内にしてください。';
                }
                return null;
              },
              minLines: 1,
              maxLines: 10,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: 'タイトル',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              onChanged: (value) => model.title = value,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${model.title.length}/80',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingTeacherModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '自己紹介',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: '経歴、趣味など',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              onChanged: (value) => model.about = value,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${model.about.length}/500',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CanDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingTeacherModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'サービス内容',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: '内容',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              onChanged: (value) => model.canDo = value,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${model.canDo.length}/500',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Recommend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingTeacherModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'こんな方におすすめ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: 'おすすめのユーザー',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              onChanged: (value) => model.recommend = value,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${model.recommend.length}/500',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
