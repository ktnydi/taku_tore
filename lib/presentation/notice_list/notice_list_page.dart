import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/notice.dart';
import 'notice_list_model.dart';

class NoticeList extends StatelessWidget {
  Widget _buildNoticeCell(BuildContext context, Notice notice) {
    switch (notice.type) {
      case 'add room':
        return _buildAddRoomCell(context, notice);
      default:
        return SizedBox();
    }
  }

  Widget _buildAddRoomCell(BuildContext context, Notice notice) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: Navigation to NoticeDetail.
        },
        child: Container(
          padding: EdgeInsets.all(15),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
      ),
      body: ChangeNotifierProvider<NoticeListModel>(
        create: (_) => NoticeListModel()..fetchNotices(),
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

            final notices = model.notices.map(
              (notice) {
                return _buildNoticeCell(context, notice);
              },
            ).toList();

            return ListView.separated(
              itemBuilder: (context, index) => notices[index],
              separatorBuilder: (context, index) => Divider(height: 0.5),
              itemCount: notices.length,
            );
          },
        ),
      ),
    );
  }
}
