import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class Review {
  Review(DocumentSnapshot doc, User user) {
    documentID = doc.id;
    rating = doc.data()['rating'].toDouble();
    comment = doc.data()['comment'];
    createdAt = doc.data()['createdAt'];
    fromUser = user;
  }

  String documentID;
  double rating;
  String comment;
  User fromUser;
  Timestamp createdAt;
}
