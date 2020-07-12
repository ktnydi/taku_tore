import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../atoms/rounded_button.dart';
import '../common/loading.dart';
import '../../user_model.dart';

class SettingName extends StatefulWidget {
  @override
  _SettingNameState createState() => _SettingNameState();
}

class _SettingNameState extends State<SettingName>
    with TickerProviderStateMixin {
  final TextEditingController _newNameController = TextEditingController();
  bool isDisabled = true;

  @override
  void dispose() {
    final _controllers = <TextEditingController>[
      _newNameController,
    ];

    _controllers.forEach((_controller) => _controller.dispose());
    super.dispose();
  }

  Future updateName(UserModel model) async {
    try {
      await model.updateName(name: _newNameController.text);

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('名前を更新しました。'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
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
    return Consumer<UserModel>(builder: (_, model, __) {
      return Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text(
                'ユーザー名の変更',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      model.user.displayName,
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
                  TextField(
                    controller: _newNameController,
                    decoration: InputDecoration(
                      hintText: 'ユーザー名',
                    ),
                    onChanged: (value) {
                      if (value.length == 0) {
                        setState(() {
                          isDisabled = true;
                        });
                        return;
                      }

                      setState(() {
                        isDisabled = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  RoundedButton(
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
                            await updateName(model);
                          },
                  ),
                ],
              ),
            ),
          ),
          Loading(model.isLoading),
        ],
      );
    });
  }
}
