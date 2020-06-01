import 'package:flutter/material.dart';

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
  @override
  _UpdateEmailFormState createState() => _UpdateEmailFormState();
}

class _UpdateEmailFormState extends State<UpdateEmailForm>
    with TickerProviderStateMixin {
  final TextEditingController _currentEmailController =
      TextEditingController(text: 'alice@example.com');
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isDisabled = true;

  @override
  void dispose() {
    // TODO: implement dispose
    final List<TextEditingController> _controllers = [
      _currentEmailController,
      _newEmailController,
      _passwordController,
    ];

    _controllers.forEach((_controller) => _controller.dispose());
    super.dispose();
  }

  void judgeValidTextField() {
    final List<TextEditingController> _controllers = [
      _currentEmailController,
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
                TextFormField(
                  controller: _currentEmailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
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
                ButtonTheme(
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
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}