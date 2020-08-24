import 'package:flutter/material.dart';
import 'user.dart';

class Teacher extends User {
  String thumbnail;
  String title;
  String about;
  String canDo;
  String recommend;
  double avgRating;
  int numRatings;
  bool isRecruiting;

  Teacher({
    @required uid,
    @required displayName,
    @required photoURL,
    @required isTeacher,
    @required blockedUserID,
    @required createdAt,
    @required this.thumbnail,
    @required this.title,
    @required this.about,
    @required this.canDo,
    @required this.recommend,
    @required this.avgRating,
    @required this.numRatings,
    @required this.isRecruiting,
  }) : super(
          uid: uid,
          displayName: displayName,
          photoURL: photoURL,
          blockedUserID: blockedUserID,
          isTeacher: isTeacher,
          createdAt: createdAt,
        );
}
