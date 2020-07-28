import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../molecule/teacher_cell.dart';
import 'home_model.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'TakuTore',
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
          IconButton(
            onPressed: () {
              // TODO: Add a future for notification lists.
            },
            icon: Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),
      body: ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()
          ..fetchTeachers()
          ..scrollListener(),
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
        if (model.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final listTiles = model.teachers.map(
          (teacher) {
            return TeacherCell(teacher: teacher);
          },
        ).toList();
        return ListView.separated(
          controller: model.scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Divider(height: 0.5),
          itemBuilder: (context, index) => listTiles[index],
          itemCount: listTiles.length,
        );
      },
    );
  }
}
