import 'package:flutter/material.dart';
import 'package:takutore/presentation/setting_teacher/setting_teacher_model.dart';

class TeacherFormConfirm extends StatelessWidget {
  TeacherFormConfirm({
    this.model,
  });

  final SettingTeacherModel model;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text('入力内容の確認'),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'サムネイル',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      model.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'タイトル',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    model.title,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'サービス内容',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    model.canDo,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'おすすめのユーザー',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    model.recommend,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '自己紹介',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    model.about,
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 30),
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextButton(
                      child: Text(
                        'この内容で講師に登録する',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        try {
                          model.beginLoading();
                          await model.registerAsTeacher();
                          model.endLoading();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } catch (e) {
                          model.endLoading();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(e.toString()),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
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
  }
}
