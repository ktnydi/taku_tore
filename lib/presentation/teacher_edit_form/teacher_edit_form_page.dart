import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/teacher.dart';
import 'teacher_edit_form_model.dart';

class TeacherEditForm extends StatelessWidget {
  TeacherEditForm(this.teacher);

  final Teacher teacher;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeacherEditFormModel>(
      create: (_) => TeacherEditFormModel(teacher),
      child: Consumer<TeacherEditFormModel>(
        builder: (_, model, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('講義内容の編集'),
            ),
          );
        },
      ),
    );
  }
}
