import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/user.dart';
import 'package:takutore/presentation/teacher_detail/teacher_detail_page.dart';
import 'home_model.dart';

class Home extends StatelessWidget {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> _confirmDialog(BuildContext context, User teacher) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ユーザーをブロックする'),
          content: Text(
            '今後、${teacher.displayName}さんに関する情報は表示されなくなります。${teacher.displayName}さんをブロックしますか？',
          ),
          actions: <Widget>[
            FlatButton(
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
            FlatButton(
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

  Future _showModalBottomSheet(
    BuildContext context,
    User teacher,
    HomeModel model,
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
                    child: FlatButton(
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
                      onPressed: () {},
                    ),
                  ),
                  ButtonTheme(
                    child: FlatButton(
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

                          _scaffoldKey.currentState.showSnackBar(snackBar);

                          await model.loading();
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                    ),
                  ),
                  ButtonTheme(
                    child: FlatButton(
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

  Widget _cell(BuildContext context, HomeModel model, User teacher) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  TeacherDetail(teacher: teacher),
            ),
          );
        },
        onLongPress: () async {
          await _showModalBottomSheet(context, teacher, model);
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(teacher.photoURL),
            radius: 25,
          ),
          title: Text(
            teacher.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '講師を探す',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // TODO: Add a future for searching teacher.
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()
          ..loading()
          ..scrollListener(),
        child: Consumer<HomeModel>(
          builder: (_, model, __) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Widget> listTiles = [];
            model.teachers.asMap().forEach(
              (key, teacher) {
                if (model.blockedUserID.contains(teacher.uid)) {
                  return;
                }
                listTiles = [...listTiles, _cell(context, model, teacher)];
              },
            );
            return RefreshIndicator(
              onRefresh: () async {
                await model.loading();
              },
              child: ListView.separated(
                controller: model.scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Divider(height: 0.5),
                itemBuilder: (context, index) => listTiles[index],
                itemCount: listTiles.length,
              ),
            );
          },
        ),
      ),
    );
  }
}
