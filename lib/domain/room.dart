import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

class Room {
  Room({
    @required this.documentId,
    @required this.teacher,
    @required this.student,
    @required this.lastMessage,
    @required this.updatedAt,
    @required this.createdAt,
    @required this.hasUnreadMessage,
    @required this.lastMessageFromUid,
  });

  final String documentId;
  final User teacher;
  final User student;
  final String lastMessage;
  final Timestamp updatedAt;
  final Timestamp createdAt;
  final bool hasUnreadMessage;
  final String lastMessageFromUid;
}
