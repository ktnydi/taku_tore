import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/teacher.dart';
import 'package:takutore/molecule/teacher_cell.dart';
import 'package:takutore/presentation/search_teacher_list/search_teacher_list_model.dart';
import 'package:takutore/user_model.dart';

class SearchTeacherList extends StatelessWidget {
  SearchTeacherList({this.text});

  final String text;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _cell(
      BuildContext context, Teacher teacher, SearchTeacherListModel model) {
    return Builder(
      builder: (context) {
        final currentUser = context.select((UserModel model) => model.user);
        return TeacherCell(
          scaffoldKey: _scaffoldKey,
          teacher: teacher,
          model: model,
          currentUser: currentUser,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchTeacherListModel>(
      create: (_) => SearchTeacherListModel(text: this.text)
        ..searchTeachers()
        ..scrollListener(),
      builder: (context, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              context.select(
                (SearchTeacherListModel model) => model.text,
              ),
            ),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView.separated(
                padding: EdgeInsets.only(bottom: 100),
                controller:
                    context.watch<SearchTeacherListModel>().scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: context
                    .select(
                      (SearchTeacherListModel model) => model.teachers,
                    )
                    .length,
                itemBuilder: (context, index) {
                  return Builder(
                    builder: (context) {
                      final model = context.select(
                        (SearchTeacherListModel model) => model,
                      );

                      final listTiles = model.teachers.map(
                        (teacher) {
                          return _cell(context, teacher, model);
                        },
                      ).toList();

                      return listTiles[index];
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 0.5),
              ),
              context.select((SearchTeacherListModel model) => model.isLoading)
                  ? Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
