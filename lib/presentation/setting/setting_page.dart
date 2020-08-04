import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/atoms/rounded_button.dart';
import '../setting_image/setting_image_page.dart';
import '../../user_model.dart';
import '../setting_teacher/setting_teacher_page.dart';
import '../remove_teacher/remove_teacher_page.dart';
import '../setting_name/setting_name_page.dart';
import '../setting_email/setting_email_page.dart';
import '../setting_password/setting_password_page.dart';
import '../bookmark/bookmark_page.dart';
import '../remove_user/remove_user_page.dart';
import '../blocked_user_list/blocked_user_list_page.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: <Widget>[
              CurrentAccount(),
              SizedBox(height: 15),
              AccountSetting(),
              SizedBox(height: 15),
              BlockedUser(),
              SizedBox(height: 15),
              Bookmark(),
              SizedBox(height: 15),
              Danger(),
            ],
          ),
        ),
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
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ログイン中のアカウント',
                style: _sectionTitleStyle,
              ),
              SizedBox(height: 20),
              Column(
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
                  SizedBox(height: 5),
                  RoundedButton(
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
                            builder: (BuildContext context) => SettingTeacher(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => RemoveTeacher(),
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccountSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Section(
          title: SectionTitle(title: 'アカウント設定'),
          children: <Widget>[
            SectionCell(
              title: Text(
                'ユーザー名',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: model.user.displayName,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SettingName(),
                  ),
                );
              },
            ),
            SectionCell(
              title: Text(
                'メールアドレス',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: model.user.email,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SettingEmail(),
                  ),
                );
              },
            ),
            SectionCell(
              title: Text(
                'パスワード',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SettingPassword(),
                  ),
                );
              },
            ),
            SectionCell(
              title: Text(
                '画像',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => SettingImage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class BlockedUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: SectionTitle(title: 'ブロック'),
      children: <Widget>[
        SectionCell(
          title: Text(
            'ブロックしたユーザー',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => BlockedUserList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class Bookmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Section(
      title: SectionTitle(title: 'ブックマーク'),
      children: <Widget>[
        SectionCell(
          title: Text(
            'ブックマーク',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => BookmarkList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class Danger extends StatelessWidget {
  void _logoutDialog(BuildContext context, UserModel model) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('ログアウトしますか?'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'キャンセル',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return Section(
          children: <Widget>[
            SectionCell(
              title: Text(
                'アカウント削除',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
            SectionCell(
              title: Text(
                'ログアウト',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _logoutDialog(context, model);
              },
            ),
          ],
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  SectionTitle({@required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    final TextStyle _sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Text(
        title,
        style: _sectionTitleStyle,
      ),
    );
  }
}

class SectionCell extends StatelessWidget {
  SectionCell({
    this.title,
    this.content = '',
    this.onTap,
  });

  final Widget title;
  final String content;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              title,
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  this.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
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
          onTap: this.onTap,
        );
      },
    );
  }
}

class Section extends StatelessWidget {
  Section({
    this.title,
    this.children,
  });

  final Widget title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title ?? Container(),
        Flexible(
          child: Ink(
            color: Colors.white,
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    index == 0 ? Divider(height: 0.5) : Container(),
                    children[index],
                    index == children.length - 1
                        ? Divider(height: 0.5)
                        : Container(),
                  ],
                );
              },
              itemCount: children.length,
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Divider(height: 0.5),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
