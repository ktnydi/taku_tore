import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../setting_teacher/setting_teacher_page.dart';
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
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  void uploadImage() async {
    try {
      // 端末から画像データを取得
      final PickedFile pickedFile =
          await picker.getImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }
      final imageData = await pickedFile.readAsBytes();

      // Firebase Storageに画像をアップロード
      final FirebaseUser currentUser = await _auth.currentUser();
      final path = '/images/${currentUser.uid}.jpg';
      final StorageReference storageRef = _storage.ref().child(path);
      final metaData = StorageMetadata(contentType: "image/jpg");
      final StorageUploadTask uploadTask = storageRef.putData(
        imageData,
        metaData,
      );

      // 画像の保存完了時にFirestoreにURLを保存する。
      StorageTaskSnapshot snapshot = await uploadTask.onComplete;
      String photoURL = await snapshot.ref.getDownloadURL();
      updateCurrentUserIcon(photoURL: photoURL);
      Navigator.pop(context);
    } catch (error) {
      print(error);
    }
  }

  void resetUserIcon() async {
    try {
      StorageReference photoRef = _storage.ref().child('/images/default.jpg');
      String photoURL = await photoRef.getDownloadURL();
      updateCurrentUserIcon(photoURL: photoURL);
      Navigator.pop(context);
    } catch (error) {
      print(error);
    }
  }

  void updateCurrentUserIcon({photoURL}) async {
    FirebaseUser currentUser = await _auth.currentUser();
    DocumentReference imgDocRef = _store.document('users/${currentUser.uid}');
    await imgDocRef.updateData({
      'photoURL': photoURL,
    });
  }

  void changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('ギャラリー'),
                onTap: uploadImage,
              ),
              ListTile(
                title: Text('デフォルトに戻す'),
                onTap: resetUserIcon,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<Map<String, dynamic>>(context);

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
                  child: StreamBuilder<Object>(
                      stream: null,
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(currentUser['photoURL']),
                          backgroundColor: Colors.transparent,
                        );
                      }),
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
//                      uploadImage();
                      changeAvatar();
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
                      // TODO: Add processing for becoming teacher.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => SettingTeacher(),
                        ),
                      );
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
                        _auth.signOut();
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
  }
}
