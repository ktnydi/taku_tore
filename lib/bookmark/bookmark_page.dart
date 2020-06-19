import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../teacher_detail/teacher_detail_page.dart';

class BookmarkList extends StatefulWidget {
  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ブックマーク',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return BookmarkCell(index: index);
        },
        itemCount: 5,
      ),
    );
  }
}

class BookmarkCell extends StatelessWidget {
  BookmarkCell({
    this.index,
  });

  final int index;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
      leading: CircleAvatar(
        child: Text('アリス'[0]),
        radius: 25,
      ),
      title: Text(
        'ここにタイトルが入ります。ここにタイトルが入ります。ここにタイトルが入ります。',
        maxLines: 2,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('アリス'),
          Row(
            children: <Widget>[
              RatingBar(
                initialRating: 3.5,
                allowHalfRating: true,
                itemSize: 20,
                itemBuilder: (BuildContext context, int index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                  );
                },
                onRatingUpdate: (_) {},
              ),
              SizedBox(width: 5),
              Text('3.5'),
              SizedBox(width: 5),
              Text('(123)'),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => TeacherDetail(),
          ),
        );
      },
    );
  }
}
