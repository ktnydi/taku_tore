import 'package:flutter/material.dart';

import 'user.dart';

class Room {
  Room({
    @required this.documentId,
    @required this.teacher,
    @required this.student,
  });

  final String documentId;
  final User teacher;
  final User student;
}
