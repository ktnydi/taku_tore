import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notice_list_model.dart';

class NoticeList extends StatelessWidget {
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
            return Center(
              child: Text(
                '新しい通知はありません。',
              ),
            );
          },
        ),
      ),
    );
  }
}
