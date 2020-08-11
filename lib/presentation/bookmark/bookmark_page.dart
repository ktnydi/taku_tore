import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:takutore/molecule/teacher_cell.dart';
import 'bookmark_model.dart';

class BookmarkList extends StatefulWidget {
  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
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
    return ChangeNotifierProvider<BookmarkModel>(
      create: (_) => BookmarkModel()..fetchBookmarks(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ブックマーク',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<BookmarkModel>(
          builder: (_, model, __) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (model.teachers.isEmpty) {
              return Center(
                child: Text(
                  'ブックマークはありません。',
                ),
              );
            }

            final listTiles = model.teachers.map(
              (teacher) {
                return ClipRect(
                  child: Slidable(
                    actionPane: SlidableBehindActionPane(),
                    actionExtentRatio: 1 / 6,
                    child: TeacherCell(teacher: teacher),
                    secondaryActions: <Widget>[
                      SlideAction(
                        color: Colors.red,
                        child: Text(
                          '削除',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          try {
                            await model.deleteBookmark(teacher);
                          } catch (e) {
                            this._alertDialog(
                              context,
                              errorText: e.toString(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ).toList();
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(height: 0.5),
              itemBuilder: (context, index) => listTiles[index],
              itemCount: listTiles.length,
            );
          },
        ),
      ),
    );
  }
}
