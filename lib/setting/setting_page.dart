import 'package:flutter/material.dart';
import '../setting_name/setting_name_page.dart';
import '../setting_email/setting_email_page.dart';
import '../setting_password/setting_password_page.dart';
import '../bookmark/bookmark_page.dart';
import '../remove_user/remove_user_page.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          CurrentAccount(),
          SizedBox(height: 20),
          AccountSetting(),
          SizedBox(height: 20),
          Bookmark(),
          SizedBox(height: 20),
          Danger(),
        ],
      ),
    );
  }
}

class CurrentAccount extends StatelessWidget {
  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'ログイン中のアカウント',
              style: _sectionTitleStyle,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      'アリス'[0],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'アリス',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'alice@example.com',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 15),
                ButtonTheme(
                  minWidth: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    child: Text(
                      '画像を変更',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Add processing for changing avatar.
                    },
                  ),
                ),
                SizedBox(height: 5),
                ButtonTheme(
                  minWidth: double.infinity,
                  height: 50,
                  child: FlatButton(
                    child: Text(
                      '講師になる',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Add processing for becoming teature.
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSetting extends StatelessWidget {
  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'アカウント設定',
              style: _sectionTitleStyle,
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'ユーザー名',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'アリス',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
            onTap: () {
              // TODO: Add Navigation.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SettingName(),
                ),
              );
            },
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'メールアドレス',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'alice@example.com',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SettingEmail(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'パスワード',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
            onTap: () {
              // TODO: Add Navigation.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SettingPassword(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Bookmark extends StatelessWidget {
  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'ブックマーク',
              style: _sectionTitleStyle,
            ),
          ),
          ListTile(
            title: Text(
              '保存した講師を見る',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
            onTap: () {
              // TODO: Add Navigation.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => BookmarkList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Danger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'アカウント削除',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => RemoveUser(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'ログアウト',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              // TODO: Add logout processing.
            },
          ),
        ],
      ),
    );
  }
}
