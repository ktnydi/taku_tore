import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'パスワードの更新',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CurrentPasswordSection(),
    );
  }
}

class CurrentPasswordSection extends StatefulWidget {
  @override
  _CurrentPasswordSectionState createState() => _CurrentPasswordSectionState();
}

class _CurrentPasswordSectionState extends State<CurrentPasswordSection> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isDisabled = true;
  bool isUpdating = false;

  @override
  void dispose() {
    final List<TextEditingController> _controllers = [
      _currentPasswordController,
      _newPasswordController,
      _newPasswordConfirmController,
    ];
    _controllers.forEach((_controller) => _controller.dispose());
    super.dispose();
  }

  void isNotEmptyField() {
    final List<TextEditingController> _controllers = [
      _currentPasswordController,
      _newPasswordController,
      _newPasswordConfirmController,
    ];

    bool isValid = _controllers.every((_controller) {
      return _controller.text.trim().isNotEmpty;
    });

    setState(() {
      isDisabled = !isValid;
    });
  }

  void updatePassword({
    String currentPassword,
    String newPassword,
    String newPasswordConfirm,
  }) async {
    setState(() {
      isUpdating = true;
    });
    final user = await FirebaseAuth.instance.currentUser();

    try {
      AuthCredential credential = EmailAuthProvider.getCredential(
        email: user.email,
        password: currentPassword,
      );
      AuthResult authResult =
          await user.reauthenticateWithCredential(credential);

      if (newPassword != newPasswordConfirm) {
        throw new StateError('パスワードを一致させてください。');
      }

      await authResult.user.updatePassword(newPassword);

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
                  '現在のパスワード',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _currentPasswordController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください。';
                    }

                    return null;
                  },
                  obscureText: true,
                  onChanged: (value) {
                    this.isNotEmptyField();
                  },
                ),
                SizedBox(height: 20),
                Text(
                  '新しいパスワード',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _newPasswordController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください。';
                    }

                    return null;
                  },
                  obscureText: true,
                  onChanged: (value) {
                    this.isNotEmptyField();
                  },
                ),
                SizedBox(height: 20),
                Text(
                  '新しいパスワードの確認',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _newPasswordConfirmController,
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return '入力してください。';
                    }

                    return null;
                  },
                  obscureText: true,
                  onChanged: (value) {
                    this.isNotEmptyField();
                  },
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
                            onPressed: !isDisabled
                                ? () {
                                    // TODO: Implement update password processing.
                                    updatePassword(
                                      currentPassword:
                                          _currentPasswordController.text,
                                      newPassword: _newPasswordController.text,
                                      newPasswordConfirm:
                                          _newPasswordConfirmController.text,
                                    );
                                  }
                                : null,
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
