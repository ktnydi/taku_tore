import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/atoms/rounded_button.dart';
import 'package:takutore/main_model.dart';
import 'package:takutore/presentation/feedback_form/feedback_form_page.dart';
import 'package:takutore/presentation/teacher_edit/teacher_edit_page.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../setting_image/setting_image_page.dart';
import '../../user_model.dart';
import '../setting_teacher/setting_teacher_page.dart';
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
              About(),
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
                      model.user.isTeacher ? '講師設定' : '講師になる',
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
                            builder: (BuildContext context) => TeacherEdit(),
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

class About extends StatelessWidget {
  Future _alertDialog(BuildContext context, {String errorText}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorText),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicationVersion = context.select(
      (MainModel value) => value.packageInfo.version,
    );

    return Section(
      title: SectionTitle(title: 'アプリについて'),
      children: <Widget>[
        SectionCell(
          title: Text(
            'アプリのフィードバックを送る',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => FeedbackForm(),
              ),
            );
          },
        ),
        SectionCell(
          title: Text(
            '利用規約',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            try {
              const url = 'https://takutore-e2ffa.firebaseapp.com/terms.html';
              if (await launcher.canLaunch(url)) {
                await launcher.launch(url);
              } else {
                throw '利用規約の読み込みに失敗しました。';
              }
            } catch (e) {
              this._alertDialog(context, errorText: e.toString());
            }
          },
        ),
        SectionCell(
          title: Text(
            'プライバシーポリシー',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            try {
              const url = 'https://takutore-e2ffa.firebaseapp.com/privacy.html';
              if (await launcher.canLaunch(url)) {
                await launcher.launch(url);
              } else {
                throw 'プライバシーポリシーの読み込みに失敗しました。';
              }
            } catch (e) {
              this._alertDialog(context, errorText: e.toString());
            }
          },
        ),
        SectionCell(
          title: Text(
            'バージョン',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: applicationVersion,
        ),
        SectionCell(
          title: Text(
            'ライセンス',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            try {
              showLicensePage(
                context: context,
                applicationVersion: applicationVersion,
                applicationName: 'TakuTore',
              );
            } catch (e) {
              this._alertDialog(context, errorText: e.toString());
            }
          },
        ),
      ],
    );
  }
}

class Danger extends StatelessWidget {
  Future<bool> _confirmDialog(context) async {
    final isConfirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ロウアウトしますか？'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                'ログアウト',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    return isConfirm;
  }

  Future _logoutDialog(BuildContext context, UserModel model) async {
    try {
      final isConfirm = await this._confirmDialog(context);

      if (!isConfirm) return;

      model.beginLoading();

      await model.signOut();

      model.endLoading();
    } catch (e, s) {
      model.endLoading();
      print(s);
      print(e);
    }
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
          trailing: this.onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                )
              : null,
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
