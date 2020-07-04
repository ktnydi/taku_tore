import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../user_model.dart';
import '../setting_teacher/setting_teacher_page.dart';
import '../remove_teacher/remove_teacher_page.dart';
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

class CurrentAccount extends StatefulWidget {
  @override
  _CurrentAccountState createState() => _CurrentAccountState();
}

class _CurrentAccountState extends State<CurrentAccount> {
  String password = '';
  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
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
                        backgroundImage: NetworkImage(model.user.photoURL),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      model.user.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      model.user.email,
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
                        onPressed: () async {
                          try {
                            String photoURL = await model.uploadImage();
                            if (photoURL == null) return;
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('画像を更新しました。'),
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
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: FlatButton(
                        child: Text(
                          model.user.isTeacher ? '講師を止める' : '講師になる',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Add processing for becoming teacher.
                          if (!model.user.isTeacher) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SettingTeacher(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RemoveTeacher(),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
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
                        model.user.displayName,
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
                        model.user.email,
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
                onTap: () async {
                  await Navigator.push(
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
      },
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
    return Consumer<UserModel>(builder: (_, model, __) {
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
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text('ログアウトしますか?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('キャンセル'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text(
                          'ログアウト',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          model.signOut();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
