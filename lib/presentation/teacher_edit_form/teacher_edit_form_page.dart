import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/teacher.dart';
import 'teacher_edit_form_model.dart';

class TeacherEditForm extends StatelessWidget {
  TeacherEditForm(this.teacher);

  final Teacher teacher;
  final _formKey = GlobalKey<FormState>();

  Future updateTeacher(context, TeacherEditFormModel model) async {
    try {
      if (_formKey.currentState.validate()) {
        model.beginLoading();

        await model.updateTeacher();

        model.endLoading();

        Navigator.pop(context);
      }
    } catch (error) {
      model.endLoading();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
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
    return ChangeNotifierProvider<TeacherEditFormModel>(
      create: (_) => TeacherEditFormModel(teacher),
      child: Consumer<TeacherEditFormModel>(
        builder: (_, model, __) {
          return Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text('講義内容の編集'),
                ),
                body: SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Thumbnail(),
                                SizedBox(height: 20),
                                Title(),
                                SizedBox(height: 20),
                                CanDo(),
                                SizedBox(height: 20),
                                Recommend(),
                                SizedBox(height: 20),
                                About(),
                                SizedBox(height: 20),
                                ButtonTheme(
                                  minWidth: double.infinity,
                                  height: 50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: FlatButton(
                                    color: Theme.of(context).primaryColor,
                                    child: Text(
                                      '講義内容を更新する',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    disabledColor: Colors.black38,
                                    onPressed: !model.disabled()
                                        ? () async {
                                            this.updateTeacher(context, model);
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              model.isLoading
                  ? Container(
                      color: Colors.white.withOpacity(0.7),
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

class Thumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'サービスサムネイル',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Consumer<TeacherEditFormModel>(
          builder: (_, model, __) {
            return InkWell(
              onTap: () async {
                // TODO: select thumbnail image
                await model.selectThumbnail();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                    child: model.imageFile != null
                        ? Image.file(
                            model.imageFile,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: model.teacher.thumbnail.isNotEmpty
                                ? Image.network(model.thumbnail)
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.black38,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'タップして画像を選択',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherEditFormModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'サービスタイトル',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: model.title,
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 80) {
                  return '80文字以内にしてください。';
                }
                return null;
              },
              minLines: 1,
              maxLines: 10,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: 'タイトル',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              maxLength: 80,
            ),
          ],
        );
      },
    );
  }
}

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherEditFormModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '自己紹介',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: model.about,
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: '経歴、趣味など',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              maxLength: 500,
            ),
          ],
        );
      },
    );
  }
}

class CanDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherEditFormModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'サービス内容',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: model.canDo,
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: '内容',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              maxLength: 500,
            ),
          ],
        );
      },
    );
  }
}

class Recommend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherEditFormModel>(
      builder: (_, model, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'こんな方におすすめ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: model.recommend,
              validator: (value) {
                if (value.trim().isEmpty) {
                  return '入力してください。';
                }
                if (value.length > 500) {
                  return '500文字以内にしてください。';
                }
                return null;
              },
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  borderSide: BorderSide.none,
                ),
                hintText: 'おすすめのユーザー',
                filled: true,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              maxLength: 500,
            ),
          ],
        );
      },
    );
  }
}
