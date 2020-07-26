import 'package:flutter/material.dart';

class Message {
  Message({
    @required this.fromUid,
    @required this.toUid,
    @required this.content,
    this.createdAt,
  });

  final String fromUid;
  final String toUid;
  final String content;
  final dynamic createdAt;
}
