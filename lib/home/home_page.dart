import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../teacher_detail/teacher_detail_page.dart';
import 'home_model.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()..fetchTeachers(),
        child: TeacherList(),
      ),
    );
  }
}

class TeacherList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(
      builder: (_, model, __) {
        final listTiles = model.teachers.map(
          (teacher) {
            return ListTile(
              contentPadding: EdgeInsets.all(15),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(teacher.photoURL),
                radius: 25,
              ),
              title: Text(
                teacher.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => TeacherDetail(
                      teacher: teacher,
                    ),
                  ),
                );
              },
            );
          },
        ).toList();
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) => listTiles[index],
          itemCount: listTiles.length,
        );
      },
    );
  }
}
