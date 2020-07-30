import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/chat_info/chat_info_model.dart';
import '../../domain/user.dart';
import '../../domain/room.dart';

class ChatInfo extends StatelessWidget {
  ChatInfo({this.user, this.room});

  final User user;
  final Room room;

  Future<bool> _confirm(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('トークを削除しますか？'),
          content: Text('トークを全て削除します。相手側のトークは削除されません。'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                '削除',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        );
      },
    );
  }

  Future _removeTalk(ChatInfoModel model) async {
    try {
      model.beginLoading();

      await model.removeTalk();

      model.endLoading();
    } catch (e) {
      model.endLoading();
      print(e.toString());
    }
  }

  Widget _buildHeader(BuildContext context, ChatInfoModel model) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(model.user.photoURL),
            radius: 32,
          ),
          SizedBox(height: 10),
          Text(
            model.user.displayName,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearTalk(BuildContext context, ChatInfoModel model) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      onTap: () async {
        final isConfirm = await _confirm(context);

        if (!isConfirm) return;

        await this._removeTalk(model);

        Navigator.pop(context);
      },
      dense: true,
      title: Center(
        child: Text(
          'トークを削除',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatInfoModel>(
      create: (_) => ChatInfoModel(user: this.user, room: this.room),
      child: Consumer<ChatInfoModel>(
        builder: (_, model, __) {
          final List<Widget> _listTiles = [
            _buildClearTalk(context, model),
          ];

          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text('トーク情報'),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(context, model),
                    SizedBox(height: 10),
                    Material(
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 0.5,
                              color: Theme.of(context).dividerColor,
                            ),
                            bottom: BorderSide(
                              width: 0.5,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => _listTiles[index],
                          separatorBuilder: (context, index) =>
                              Divider(height: 0.5),
                          itemCount: _listTiles.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              model.isLoading
                  ? Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }
}
