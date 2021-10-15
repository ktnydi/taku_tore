import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/remove_teacher/remove_teacher_page.dart';
import 'package:takutore/presentation/teacher_edit_form/teacher_edit_form_page.dart';
import 'teacher_edit_model.dart';

class TeacherEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeacherEditModel>(
      create: (_) => TeacherEditModel()..fetchTeacher(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('講師設定'),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Text(
                  '基本設定',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Divider(height: 0.5),
              Consumer<TeacherEditModel>(
                builder: (_, model, __) {
                  return Ink(
                    color: Colors.white,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 15,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '内容を編集する',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                TeacherEditForm(model.teacher),
                          ),
                        );

                        model.fetchTeacher();
                      },
                    ),
                  );
                },
              ),
              Divider(height: 0.5),
              Consumer<TeacherEditModel>(
                builder: (_, model, __) {
                  return Ink(
                    color: Colors.white,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 15,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '募集を停止する',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          !model.isLoading
                              ? Switch(
                                  value: !model.isRecruiting,
                                  onChanged: (isRecruiting) {
                                    model.switchRecruiting(!isRecruiting);
                                  },
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Divider(height: 0.5),
              SizedBox(height: 15),
              Divider(height: 0.5),
              Consumer<TeacherEditModel>(
                builder: (_, model, __) {
                  return Ink(
                    color: Colors.white,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 15,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '講師を止める',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),
                      onTap: () async {
                        try {
                          if (await model.hasStudents()) {
                            throw ('相談中の相手がいるため、講師を止めることができません。');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RemoveTeacher(),
                            ),
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('エラー'),
                                content: Text(e.toString()),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              Divider(height: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}
