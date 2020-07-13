import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../domain/user.dart';
import '../presentation/teacher_detail/teacher_detail_page.dart';

class TeacherCell extends StatelessWidget {
  TeacherCell({@required this.teacher});

  final User teacher;
  @override
  Widget build(BuildContext context) {
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
  }
}
