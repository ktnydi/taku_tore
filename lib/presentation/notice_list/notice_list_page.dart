import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/user_model.dart';
import '../chat_room/chat_room_page.dart';
import 'notice_list_model.dart';

class NoticeList extends StatelessWidget {
  Widget _buildNoticeCell(
      BuildContext context, int index, NoticeListModel model) {
    switch (model.notices[index].type) {
      case 'add room':
        return _buildAddRoomCell(context, index, model);
      default:
        return SizedBox();
    }
  }

  Widget _buildAddRoomCell(
    BuildContext context,
    int index,
    NoticeListModel model,
  ) {
    final notice = model.notices[index];

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ChatRoom(
                user: notice.sender,
                room: model.room,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(notice.sender.photoURL),
                    ),
                    SizedBox(width: 15),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: notice.sender.displayName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: 'さんが${notice.message}',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            notice.createdAt,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select((UserModel model) => model.user);
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
      ),
      body: currentUser != null
          ? ChangeNotifierProvider<NoticeListModel>(
              create: (_) => NoticeListModel()
                ..fetchNotices()
                ..readNotice(),
              child: Consumer<NoticeListModel>(
                builder: (_, model, __) {
                  if (model.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (model.notices.isEmpty) {
                    return Center(
                      child: Text(
                        '新しい通知はありません。',
                      ),
                    );
                  }

                  return ListView.separated(
                    itemBuilder: (context, index) {
                      return _buildNoticeCell(
                        context,
                        index,
                        model,
                      );
                    },
                    separatorBuilder: (context, index) => Divider(height: 0.5),
                    itemCount: model.notices.length,
                  );
                },
              ),
            )
          : SizedBox(),
    );
  }
}
