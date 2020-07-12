import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class SettingPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                title: Text(
                  'パスワードの更新',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: CurrentPasswordSection(),
            ),
            Loading(model.isLoading),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (_, model, __) {
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
                        ? RoundedButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              '更新',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: !isDisabled
                                ? () async {
                                    // TODO: Implement update password processing.
                                    try {
                                      await model.updatePassword(
                                        currentPassword:
                                            _currentPasswordController.text,
                                        newPassword:
                                            _newPasswordController.text,
                                        newPasswordConfirm:
                                            _newPasswordConfirmController.text,
                                      );
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('パスワードを更新しました。'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('OK'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      model.checkUserSignIn();
                                      Navigator.pop(context);
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
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                : null,
                          )
                        : CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
