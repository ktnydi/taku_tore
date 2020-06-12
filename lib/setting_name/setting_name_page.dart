import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingName extends StatefulWidget {
  SettingName({this.currentUser});

  final Map<String, dynamic> currentUser;

  @override
  _SettingNameState createState() => _SettingNameState();
}

class _SettingNameState extends State<SettingName>
    with TickerProviderStateMixin {
  final Firestore _store = Firestore.instance;
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

  void updateName({newName}) async {
    try {
      _store.document('users/${widget.currentUser['uid']}').updateData({
        'displayName': newName,
      });
      Navigator.pop(context);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                widget.currentUser['displayName'],
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
                      : () => updateName(newName: _newNameController.text)),
            ),
          ],
        ),
      ),
    );
  }
}
