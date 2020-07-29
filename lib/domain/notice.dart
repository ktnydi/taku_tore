import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart';
import 'user.dart';

class Notice {
  String type;
  Map<String, dynamic> data;
  String createdAt;
  User sender;
  String message;
  Firestore _store = Firestore.instance;

  Notice(DocumentSnapshot doc) {
    this.type = doc['type'];
    this.data = doc['data'];
    this.createdAt = format(doc['createdAt'].toDate());
    this.message = _typeParser(doc['type']);
  }

  String _typeParser(String type) {
    switch (type) {
      case 'add room':
        return 'トークルームを作成しました';
      default:
        return '';
    }
  }

  Future<void> fetchSender() async {
    final document = _store.collection('users').document(this.data['senderID']);
    final doc = await document.get();
    final sender = User(
      uid: doc.documentID,
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      isTeacher: doc['isTeacher'],
      createdAt: doc['createdAt'],
    );
    this.sender = sender;
  }
}
