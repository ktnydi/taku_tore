import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  User({
    @required this.uid,
    @required this.displayName,
    @required this.photoURL,
    @required this.isTeacher,
    this.email,
    this.thumbnail,
    this.title,
    this.about,
    this.canDo,
    this.recommend,
    this.avgRating,
    this.numRatings,
    this.blockedUserID,
    @required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String photoURL;
  final bool isTeacher;
  final String email;
  final String thumbnail;
  final String title;
  final String about;
  final String canDo;
  final String recommend;
  final double avgRating;
  final double numRatings;
  final List<dynamic> blockedUserID;
  final Timestamp createdAt;
}
