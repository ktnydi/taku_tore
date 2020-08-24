import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  User({
    @required this.uid,
    @required this.displayName,
    @required this.photoURL,
    @required this.isTeacher,
    @required this.createdAt,
    @required this.blockedUserID,
    this.email,
  });

  final String uid;
  final String displayName;
  final String photoURL;
  final bool isTeacher;
  final String email;
  final List<dynamic> blockedUserID;
  final Timestamp createdAt;
}
