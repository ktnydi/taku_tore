import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isObscureText = true;
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    final List<TextEditingController> _controllers = [
      _nameController,
      _emailController,
      _passwordController,
    ];
    _controllers.forEach((_controller) => _controller.dispose());
  }

  void signup() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        StorageReference photoRef =
            FirebaseStorage.instance.ref().child('/images/default.jpg');
        String photoURL = await photoRef.getDownloadURL();
        AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (_result.user != null) {
          FirebaseUser currentUser = _result.user;
          await _store.document('users/${currentUser.uid}').setData({
            'displayName': _nameController.text,
            'photoURL': photoURL,
            'about': '',
            'isTeacher': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          Navigator.pop(context);
        }
      } catch (error) {
        _authDialog(error.message);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _authDialog(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            ButtonTheme(
              minWidth: 0,
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '閉じる',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'アカウント作成',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'ユーザー名',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'メールアドレス',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      return null;
                    },
                    obscureText: isObscureText,
                    decoration: InputDecoration(
                      hintText: 'パスワード',
                      suffixIcon: ButtonTheme(
                        minWidth: 0.0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        child: FlatButton(
                          child: Text(
                            isObscureText ? '表示' : '隠す',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              isObscureText = !isObscureText;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: !isLoading
                        ? ButtonTheme(
                            minWidth: double.infinity,
                            height: 50,
                            textTheme: ButtonTextTheme.primary,
                            child: RaisedButton(
                              child: Text(
                                'アカウント作成',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: signup,
                            ),
                          )
                        : CircularProgressIndicator(),
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
