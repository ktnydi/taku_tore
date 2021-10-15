import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:takutore/domain/teacher.dart';
import 'package:takutore/domain/user.dart';
import 'package:takutore/presentation/bookmark/bookmark_model.dart';
import 'package:takutore/presentation/home/home_model.dart';
import 'package:takutore/presentation/search_teacher_list/search_teacher_list_model.dart';
import '../presentation/teacher_detail/teacher_detail_page.dart';

class TeacherCell extends StatelessWidget {
  TeacherCell({
    @required this.scaffoldKey,
    @required this.teacher,
    @required this.model,
    @required this.currentUser,
  }) : assert(model.runtimeType == HomeModel ||
            model.runtimeType == SearchTeacherListModel ||
            model.runtimeType == BookmarkModel);

  final Teacher teacher;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final dynamic model;
  final User currentUser;

  Future _alertDialog(BuildContext context, {String errorText}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorText),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDialog(BuildContext context, Teacher teacher) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ユーザーをブロックする'),
          content: Text(
            '今後、${teacher.displayName}さんに関する情報は表示されなくなります。${teacher.displayName}さんをブロックしますか？',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text(
                'ブロック',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future _report(BuildContext context,
      {dynamic model, Teacher teacher, String contentType}) async {
    final types = ['inappropriate', 'spam'];
    try {
      if (!types.contains(contentType)) {
        throw ('適切な報告内容を選択してください。');
      }

      await model.report(
        user: teacher,
        contentType: 'inappropriate',
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ご報告ありがとうございます'),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      this._alertDialog(
        context,
        errorText: e.toString(),
      );
    }
  }

  Future _addBlocked(BuildContext context,
      {dynamic model, User teacher}) async {
    try {
      Navigator.pop(context);

      final isConfirm = await this._confirmDialog(
        context,
        teacher,
      );

      if (!isConfirm) return;

      await model.blockedUser(user: teacher);

      final snackBar = SnackBar(
        content: Text(
          '${teacher.displayName}さんをブロックしました',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      await model.loading();
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(
          e.toString(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _showModalBottomSheet(
    BuildContext context,
    User teacher,
    dynamic model,
  ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ButtonTheme(
                    child: TextButton(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.outlined_flag,
                            size: 18,
                          ),
                          SizedBox(width: 20),
                          Text(
                            '報告する',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        Navigator.pop(context);

                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              titlePadding: EdgeInsets.all(15),
                              contentPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: Center(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'ユーザーを報告する',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '報告したい内容を選択してください',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: <Widget>[
                                Divider(height: 0.5),
                                SimpleDialogOption(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      '不適切な内容である',
                                    ),
                                  ),
                                  onPressed: () async {
                                    await this._report(
                                      context,
                                      model: model,
                                      teacher: teacher,
                                      contentType: 'inappropriate',
                                    );
                                  },
                                ),
                                Divider(height: 0.5),
                                SimpleDialogOption(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      'スパムである',
                                    ),
                                  ),
                                  onPressed: () async {
                                    await this._report(
                                      context,
                                      model: model,
                                      teacher: teacher,
                                      contentType: 'spam',
                                    );
                                  },
                                ),
                                Divider(height: 0.5),
                                SimpleDialogOption(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text('キャンセル'),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Divider(height: 0.5),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  ButtonTheme(
                    child: TextButton(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.block,
                            size: 18,
                          ),
                          SizedBox(width: 20),
                          Text(
                            '${teacher.displayName}さんをブロックする',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await _addBlocked(
                          context,
                          model: model,
                          teacher: teacher,
                        );
                      },
                    ),
                  ),
                  ButtonTheme(
                    child: TextButton(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.close,
                            size: 18,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'キャンセル',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherDetail(teacher: teacher),
            ),
          );
        },
        onLongPress: currentUser != null
            ? () async {
                await _showModalBottomSheet(context, teacher, model);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black12, width: 0.5),
                  image: DecorationImage(
                    image: NetworkImage(teacher.photoURL),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      teacher.displayName,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        RatingBarIndicator(
                          rating: teacher.avgRating.toDouble(),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20,
                        ),
                        SizedBox(width: 3),
                        Text(
                          '${teacher.avgRating}',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          '(${teacher.numRatings})',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              currentUser != null
                  ? Transform.translate(
                      offset: Offset(0, -8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.more_vert),
                        ),
                        onTap: () async {
                          await _showModalBottomSheet(context, teacher, model);
                        },
                      ),
                    )
                  : SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}
