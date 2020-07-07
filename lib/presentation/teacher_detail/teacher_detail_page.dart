import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';
import '../../domain/user.dart';
import '../../user_model.dart';
import '../review/review_page.dart';
import 'teacher_detail_model.dart';

class TeacherDetail extends StatelessWidget {
  TeacherDetail({this.teacher});

  final User teacher;

  Future addBookmark({
    @required TeacherDetailModel model,
    @required BuildContext context,
  }) async {
    try {
      model.teacher = teacher;

      await model.addBookmark();

      model.checkBookmark(teacher: teacher);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }
  }

  Future deleteBookmark({
    @required TeacherDetailModel model,
    @required BuildContext context,
  }) async {
    try {
      model.teacher = teacher;

      await model.deleteBookmark();

      model.checkBookmark(teacher: teacher);
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeacherDetailModel>(
      create: (_) => TeacherDetailModel()
        ..checkAuthor(teacher: teacher)
        ..checkBookmark(teacher: teacher)
        ..checkRoom(teacher: teacher)
        ..fetchReviews(teacher: teacher)
        ..scrollListener(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: false,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.all(16),
                child: Transform.translate(
                  offset: Offset(-1, 0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                color: Colors.black45,
                shape: CircleBorder(),
                onPressed: () => Navigator.pop(context),
              ),
              Consumer2<UserModel, TeacherDetailModel>(
                builder: (_, userModel, teacherDetailModel, __) {
                  if (teacher.uid == userModel.user.uid) {
                    return Container();
                  }

                  return FlatButton(
                    child: Icon(
                      teacherDetailModel.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.white,
                      size: 18,
                    ),
                    color: Colors.black45,
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                    onPressed: () async {
                      if (teacherDetailModel.isBookmarked) {
                        await deleteBookmark(
                          model: teacherDetailModel,
                          context: context,
                        );
                      } else {
                        await addBookmark(
                          model: teacherDetailModel,
                          context: context,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: Consumer<TeacherDetailModel>(
          builder: (_, model, __) {
            return SingleChildScrollView(
              controller: model.scrollController,
              child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Column(
                  children: <Widget>[
                    Header(teacher: teacher),
                    Content(teacher: teacher),
                    ReviewList(),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingButton(teacher),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  FloatingButton(this.teacher);

  final User teacher;

  Future<bool> _showDialog({
    BuildContext context,
    String title,
    String content,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future consult({
    BuildContext context,
    TeacherDetailModel model,
  }) async {
    try {
      final isConfirm = await _showDialog(
        context: context,
        title: '確認',
        content: '${teacher.displayName}さんに相談しますか？',
      );

      if (!isConfirm) return;

      await model.addRoom();

      _showDialog(
        context: context,
        title: '確認',
        content: 'チャットルームを作成しました。',
      );

      model.checkRoom(teacher: teacher);
    } catch (e) {
      model.endLoading();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text(e.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDetailModel>(
      builder: (_, model, __) {
        if (model.isAuthor) {
          return Container();
        }

        const horizontalMargin = 30;
        return ButtonTheme(
          minWidth: MediaQuery.of(context).size.width - horizontalMargin,
          height: 50,
          child: FlatButton(
            color: !model.isAlreadyExist
                ? Theme.of(context).primaryColor
                : Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            onPressed: !model.isAlreadyExist
                ? () async {
                    await consult(context: context, model: model);
                  }
                : () {
                    // TODO: write review
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (BuildContext context) => Review(
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
            child: !model.isLoading
                ? Text(
                    !model.isAlreadyExist ? '相談する' : 'レビューを書く',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  )
                : CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  Header({this.teacher});

  final User teacher;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            teacher.photoURL,
          ),
        ),
      ),
    );
  }
}

class Content extends StatelessWidget {
  Content({this.teacher});

  final User teacher;

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDetailModel>(
      builder: (_, model, __) {
        model.teacher = teacher;

        return Padding(
          padding: const EdgeInsets.only(
            top: 15,
            right: 15,
            bottom: 0,
            left: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Title(teacher.title),
              Divider(height: 20),
              Teacher(teacher),
              Divider(height: 20),
              Description(
                title: 'サービス内容',
                content: teacher.canDo,
              ),
              SizedBox(height: 15),
              Description(
                title: 'こんな方におすすめ',
                content: teacher.recommend,
              ),
              SizedBox(height: 15),
              Description(
                title: '自己紹介',
                content: teacher.about,
              ),
            ],
          ),
        );
      },
    );
  }
}

class Title extends StatelessWidget {
  Title(this.title);

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}

class Teacher extends StatelessWidget {
  Teacher(this.teacher);

  final User teacher;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(
            teacher.photoURL,
          ),
        ),
        SizedBox(width: 10),
        Text(
          teacher.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class Description extends StatelessWidget {
  Description({@required this.title, @required this.content});

  final String title;
  final String content;

  TextStyle _label() {
    return TextStyle(
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle _description() {
    return TextStyle(
      fontSize: 16,
      color: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: _label(),
        ),
        SizedBox(height: 5),
        Text(
          content,
          style: _description(),
        ),
      ],
    );
  }
}

class ReviewList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(
            height: 30,
          ),
          Text(
            'レビュー',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Consumer<TeacherDetailModel>(
            builder: (_, model, __) {
              if (model.reviews.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.black12,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Center(
                          child: Text(
                            'レビューはまだありません。',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListBody(
                children: model.reviews.map(
                  (review) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                            review.fromUser.photoURL,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RatingBarIndicator(
                              rating: review.rating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20,
                            ),
                            SizedBox(height: 5),
                            Text(
                              review.comment,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    review.fromUser.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  '・${format(review.createdAt.toDate())}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
