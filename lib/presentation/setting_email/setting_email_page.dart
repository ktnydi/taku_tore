import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class SettingEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                title: Text(
                  'メールアドレスの変更',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: UpdateEmailForm(),
            ),
            Loading(model.isLoading),
          ],
        );
      },
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
                    '現在',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      model.user.email,
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
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
                            onPressed: isDisabled
                                ? null
                                : () async {
                                    // TODO: Implement processing for updating email.
                                    try {
                                      await model.updateEmail(
                                        email: _newEmailController.text,
                                        password: _passwordController.text,
                                      );
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('メールアドレスを更新しました。'),
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
                                  },
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
