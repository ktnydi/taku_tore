import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class Review {
  Review(Map<String, dynamic> map, User user) {
    documentID = map['id'];
    rating = map['rating'].toDouble();
    comment = map['comment'];
    createdAt = map['createdAt'];
    fromUser = user;
  }

  String documentID;
  double rating;
  String comment;
  User fromUser;
  Timestamp createdAt;
}
