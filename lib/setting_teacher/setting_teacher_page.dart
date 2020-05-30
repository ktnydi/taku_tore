import 'package:flutter/material.dart';

class SettingTeacher extends StatefulWidget {
  @override
  _SettingTeacherState createState() => _SettingTeacherState();
}

class _SettingTeacherState extends State<SettingTeacher> {
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
          FlatButton(
            child: Text(
              '次へ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                // TODO: Implement processing for becoming teacher.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => BecomeTeacher(),
                  ),
                );
                return null;
              }
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
    );
  }
}

class BecomeTeacher extends StatefulWidget {
  @override
  _BecomeTeacherState createState() => _BecomeTeacherState();
}

class _BecomeTeacherState extends State<BecomeTeacher>
    with TickerProviderStateMixin {
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _canDoController = TextEditingController();
  TextEditingController _recommendController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    List<TextEditingController> _controllers = [
      _aboutController,
      _canDoController,
      _recommendController,
    ];
    _controllers.forEach((_controller) => _controller.dispose());
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      // TODO: Implement processing for registering as teacher.
    }
    // TODO: Implement processing when failure.
  }

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
          FlatButton(
            child: Text(
              '登録',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: this._submit,
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
                  Padding(
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
                                  'https://images.pexels.com/photos/3963122/pexels-photo-3963122.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'アリス',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    controller: _aboutController,
                    validator: (value) {
                      print(value);
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
                    controller: _canDoController,
                    validator: (value) {
                      print(value);
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
                    controller: _recommendController,
                    validator: (value) {
                      print(value);
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
