import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/domain/teacher.dart';
import 'package:takutore/molecule/teacher_cell.dart';
import 'package:takutore/presentation/search_teacher/search_teacher_page.dart';
import 'package:takutore/user_model.dart';
import 'home_model.dart';

class Home extends StatelessWidget {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _cell(BuildContext context, HomeModel model, Teacher teacher) {
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '講師を探す',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => SearchTeacher(),
                ),
              );
            },
          )
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
