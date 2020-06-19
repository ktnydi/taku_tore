import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '講師になる',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          Consumer<UserModel>(builder: (_, model, __) {
            return FlatButton(
              child: Text(
                '次へ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
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
              },
            );
          }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
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
          Container(
            child: isLoading
                ? Container(
                    color: Colors.black26,
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class BecomeTeacher extends StatefulWidget {
  @override
  _BecomeTeacherState createState() => _BecomeTeacherState();
}

class _BecomeTeacherState extends State<BecomeTeacher>
    with TickerProviderStateMixin {
  String about = '';
  String canDo = '';
  String recommend = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '講師に登録',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          Consumer<UserModel>(
            builder: (_, model, __) {
              return FlatButton(
                child: Text(
                  '登録',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  try {
                    if (_formKey.currentState.validate()) {
                      model.registerAsTeacher(
                        about: about,
                        canDo: canDo,
                        recommend: recommend,
                      );
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
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Consumer<UserModel>(
                    builder: (_, model, __) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                        ),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      model.user.photoURL,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                model.user.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Text(
                    '自己紹介',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'あなたの経歴、活動、趣味など',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    minLines: 3,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '自己紹介を追加',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                    ),
                    onChanged: (value) => about = value,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'できること',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'フィットネス講師としてできることについて',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    minLines: 3,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'できることを追加',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                    ),
                    onChanged: (value) => canDo = value,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'こんな方におすすめ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'どのユーザーにお勧めしたいか',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    minLines: 3,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'こんな方におすすめを追加',
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                    ),
                    onChanged: (value) => recommend = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
