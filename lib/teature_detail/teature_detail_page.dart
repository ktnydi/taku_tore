import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TeatureDetail extends StatelessWidget {
  TeatureDetail({this.index});

  final int index;

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
                TeatureImage(),
                Content(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeatureImage extends StatelessWidget {
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
                'https://images.pexels.com/photos/3963122/pexels-photo-3963122.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
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
                'https://images.pexels.com/photos/3963122/pexels-photo-3963122.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Content extends StatelessWidget {
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
            'ここにタイトルが入ります。ここにタイトルが入ります。ここにタイトルが入ります。',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                '3.5',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              SizedBox(width: 5),
              RatingBar(
                initialRating: 3.5,
                allowHalfRating: true,
                itemSize: 25,
                itemBuilder: (BuildContext context, int index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                  );
                },
                onRatingUpdate: (_) {},
              ),
              Spacer(),
              ButtonTheme(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: FlatButton(
                  child: Text(
                    'コメントを見る',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Divider(),
          SizedBox(height: 15),
          Text(
            '名前 / 年齢',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            'アリス / 28',
            style: _description(),
          ),
          SizedBox(height: 15),
          Text(
            '自己紹介',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            'ここにテキストが入ります。ここにテキストが入ります。ここにテキストが入ります。',
            style: _description(),
          ),
          SizedBox(height: 15),
          Text(
            'できること',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            'ここにテキストが入ります。ここにテキストが入ります。ここにテキストが入ります。',
            style: _description(),
          ),
          SizedBox(height: 15),
          Text(
            'こんな方におすすめ',
            style: _label(),
          ),
          SizedBox(height: 5),
          Text(
            'ここにテキストが入ります。ここにテキストが入ります。ここにテキストが入ります。',
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
