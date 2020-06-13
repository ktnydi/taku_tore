import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'メールアドレスの変更',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: UpdateEmailForm(),
    );
  }
}

class UpdateEmailForm extends StatefulWidget {
  UpdateEmailForm({this.currentUser});

  final Map<String, dynamic> currentUser;
  @override
  _UpdateEmailFormState createState() => _UpdateEmailFormState();
}

class _UpdateEmailFormState extends State<UpdateEmailForm>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isDisabled = true;
  bool isUpdating = false;

  @override
  void dispose() {
    // TODO: implement dispose
    final List<TextEditingController> _controllers = [
      _newEmailController,
      _passwordController,
    ];

    _controllers.forEach((_controller) => _controller.dispose());
    super.dispose();
  }

  void judgeValidTextField() {
    final List<TextEditingController> _controllers = [
      _newEmailController,
      _passwordController,
    ];

    bool isValid = _controllers.every((_controller) {
      return _controller.text.trim().isNotEmpty;
    });

    setState(() {
      isDisabled = !isValid;
    });
  }

  void updateEmail({newEmail, password}) async {
    setState(() {
      isUpdating = true;
    });
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    try {
      AuthCredential credential = EmailAuthProvider.getCredential(
        email: user.email,
        password: password,
      );
      AuthResult authResult =
          await user.reauthenticateWithCredential(credential);

      await authResult.user.updateEmail(newEmail);

      Navigator.pop(context);
    } catch (error) {
      showDialog(
        barrierDismissible: false,
        context: context,
        child: AlertDialog(
          title: Text('エラー'),
          content: Text(error.message),
          actions: <Widget>[
            FlatButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '現在',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder(
                    future: _auth.currentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        final FirebaseUser currentUser = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            currentUser.email,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        );
                      }
                      return Container();
                    }),
                SizedBox(height: 10),
                Text(
                  '新規',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _newEmailController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください。';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'メールアドレス',
                  ),
                  onChanged: (_) => this.judgeValidTextField(),
                ),
                SizedBox(height: 30),
                Text(
                  '現在のパスワード',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください。';
                    }

                    return null;
                  },
                  obscureText: true,
                  onChanged: (_) => this.judgeValidTextField(),
                ),
                SizedBox(height: 30),
                Center(
                  child: !isUpdating
                      ? ButtonTheme(
                          minWidth: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            disabledColor: Colors.black45,
                            child: Text(
                              '更新',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: isDisabled
                                ? null
                                : () {
                                    // TODO: Implement processing for updating email.
                                    updateEmail(
                                      newEmail: _newEmailController.text,
                                      password: _passwordController.text,
                                    );
                                  },
                          ),
                        )
                      : CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
