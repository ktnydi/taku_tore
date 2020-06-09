import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RemoveUser extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> hasAvatar({FirebaseUser user}) async {
    try {
      await _storage.ref().child('/images/${user.uid}').getDownloadURL();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  void removeUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    if (currentUser != null) {
      await _store.document('/users/${currentUser.uid}').delete();
      if (await hasAvatar(user: currentUser)) {
        _storage.ref().child('/images/${currentUser.uid}').delete();
      }
      await currentUser.delete();
    }
  }

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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('本当に削除しますか？'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('キャンセル'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              '削除する',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                removeUser();
                              } catch (error) {
                                print(error);
                              } finally {
                                // アラート非表示
                                Navigator.pop(context);
                              }
                              // 設定画面に戻る
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
