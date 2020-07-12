import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
        if (model.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final listTiles = model.teachers.map(
          (teacher) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(teacher.photoURL),
                radius: 25,
              ),
              title: Text(
                teacher.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(teacher.displayName),
                  Row(
                    children: <Widget>[
                      RatingBarIndicator(
                        rating: teacher.avgRating.toDouble(),
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '${teacher.avgRating}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text('(${teacher.numRatings})'),
                    ],
                  ),
                ],
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
