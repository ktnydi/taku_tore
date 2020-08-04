import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blocked_user_list_model.dart';

class BlockedUserList extends StatelessWidget {
  Future _showDialog(BuildContext context, String errorText) async {
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
            )
          ],
        );
      },
    );
  }

  Widget _cell(BuildContext context, BlockedUserListModel model, int index) {
    final user = model.blockedUsers[index];
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(user.photoURL),
          radius: 25,
        ),
        title: Text(user.displayName),
        trailing: ButtonTheme(
          height: 40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FlatButton(
            color: Colors.redAccent,
            child: Text(
              'ブロック中',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              try {
                await model.removeBlock(user: user);

                model.fetchBlockedUsers();
              } catch (e) {
                this._showDialog(
                  context,
                  e.toString(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BlockedUserListModel>(
      create: (_) => BlockedUserListModel()..fetchBlockedUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ブロックしたユーザー'),
        ),
        body: Consumer<BlockedUserListModel>(
          builder: (_, model, __) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.separated(
              itemBuilder: (context, index) => _cell(context, model, index),
              separatorBuilder: (context, index) => Divider(height: 0.5),
              itemCount: model.blockedUsers.length,
            );
          },
        ),
      ),
    );
  }
}
