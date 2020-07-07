import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class Review {
  Review(DocumentSnapshot doc, User user) {
    documentID = doc.documentID;
    rating = doc['rating'].toDouble();
    comment = doc['comment'];
    createdAt = doc['createdAt'];
    fromUser = user;
  }

  String documentID;
  double rating;
  String comment;
  User fromUser;
  Timestamp createdAt;
}
