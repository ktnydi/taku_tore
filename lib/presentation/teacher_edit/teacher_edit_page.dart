import 'package:flutter/material.dart';

class TeacherEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('講師設定'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Text(
                '基本設定',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Divider(height: 0.5),
            Ink(
              color: Colors.white,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '内容を編集する',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
                onTap: () {},
              ),
            ),
            Divider(height: 0.5),
            Ink(
              color: Colors.white,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '募集を停止する',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: false,
                      onChanged: (value) => {},
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 0.5),
            SizedBox(height: 15),
            Divider(height: 0.5),
            Ink(
              color: Colors.white,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '講師を止める',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
                onTap: () {},
              ),
            ),
            Divider(height: 0.5),
          ],
        ),
      ),
    );
  }
}
