import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user.dart';

class Message {
  Message({
    @required this.from,
    @required this.to,
    @required this.content,
    @required this.createdAt,
  });

  final User from;
  final User to;
  final String content;
  final Timestamp createdAt;
}
