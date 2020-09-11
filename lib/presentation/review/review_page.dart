import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/teacher.dart';
import 'review_model.dart';

class Review extends StatelessWidget {
  Review({this.teacher});

  final Teacher teacher;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final reviewModel = ReviewModel();
        reviewModel.teacher = teacher;
        return reviewModel;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            title: Text(
              'レビューを書く',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              color: Colors.transparent,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ReviewForm(),
                    SizedBox(height: 20),
                    Submit(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewModel>(
      builder: (_, model, __) {
        return Form(
          key: model.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '評価',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RatingBar(
                    glowColor: Colors.white,
                    unratedColor: Colors.black12,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    minRating: 1,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      model.rating = rating;
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${model.rating}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'コメント',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return '入力してください。';
                      }
                      if (value.length > 200) {
                        return '200文字以内にしてください。';
                      }
                      return null;
                    },
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'サービスを受けた感想など',
                    ),
                    onChanged: (value) {
                      model.comment = value;
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${model.comment.length}/200',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class Submit extends StatelessWidget {
  Future<bool> _showDialog(
      {BuildContext context, String title, String message}) async {
    final isConfirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    return isConfirm ?? false;
  }

  Future _noticeDialog(
      {BuildContext context, String title, String message}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  Future addReview({BuildContext context, ReviewModel model}) async {
    try {
      final isConfirm = await _showDialog(
        context: context,
        title: '確認',
        message: '投稿しますか？',
      );

      if (!isConfirm) return;

      await model.addReview();

      await _noticeDialog(
        context: context,
        title: '完了',
        message: 'レビューを投稿しました。',
      );

      Navigator.pop(context);
    } catch (e) {
      model.endLoading();
      await _noticeDialog(
        context: context,
        title: 'エラー',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewModel>(
      builder: (_, model, __) {
        return Column(
          children: <Widget>[
            ButtonTheme(
              minWidth: double.infinity,
              height: 50,
              child: FlatButton(
                color: Colors.amber,
                disabledColor: Colors.amber,
                child: !model.isLoading
                    ? Text(
                        '投稿する',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                onPressed: !model.isLoading
                    ? () async {
                        if (model.formKey.currentState.validate()) {
                          await addReview(context: context, model: model);
                        }
                      }
                    : null,
              ),
            ),
            SizedBox(height: 10),
            ButtonTheme(
              minWidth: double.infinity,
              height: 50,
              child: FlatButton(
                child: Text(
                  '閉じる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                onPressed: !model.isLoading
                    ? () async {
                        if (model.rating == 0 && model.comment.isEmpty) {
                          return Navigator.pop(context);
                        }

                        final isConfirm = await this._showDialog(
                          context: context,
                          title: '確認',
                          message: '編集した内容を破棄します。よろしいですか？',
                        );

                        if (isConfirm) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
