import 'dart:ui';
import 'package:flutter/material.dart';
import '../user.dart';

class TeacherDetail extends StatelessWidget {
  TeacherDetail({this.teacher});

  final User teacher;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                TeacherImage(teacher: teacher),
                Content(
                  teacher: teacher,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherImage extends StatelessWidget {
  TeacherImage({this.teacher});

  final User teacher;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 230,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                teacher.photoURL,
              ),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 0),
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 1),
                blurRadius: 10,
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                teacher.photoURL,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Content extends StatelessWidget {
  Content({this.teacher});

  final User teacher;

  TextStyle _label() {
    return TextStyle(
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle _description() {
    return TextStyle(
      fontSize: 16,
      color: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            teacher.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 5),
          Divider(),
          SizedBox(height: 15),
          Text(
            '自己紹介',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            teacher.about,
            style: _description(),
          ),
          SizedBox(height: 15),
          Text(
            'できること',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            teacher.canDo,
            style: _description(),
          ),
          SizedBox(height: 15),
          Text(
            'こんな方におすすめ',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            teacher.recommend,
            style: _description(),
          ),
          SizedBox(height: 15),
          ButtonTheme(
            minWidth: double.infinity,
            height: 50.0,
            child: RaisedButton(
              child: Text(
                '相談する',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
