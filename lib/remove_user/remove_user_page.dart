import 'package:flutter/material.dart';

class RemoveUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'アカウント削除',
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
              '注意',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'アカウントを削除するとTakuToreに関するデータは全て削除され、二度と元に戻せなくなります。',
            ),
            SizedBox(height: 30),
            ButtonTheme(
              minWidth: double.infinity,
              height: 50,
              buttonColor: Colors.white,
              child: RaisedButton(
                textColor: Colors.redAccent,
                child: Text(
                  'アカウントを削除する',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // TODO: Implement processing for removing account.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
