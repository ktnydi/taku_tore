import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart';
import 'user.dart';
import 'room.dart';

class Notice {
  String _senderID;
  String type;
  Map<String, dynamic> data;
  String createdAt;
  User sender;
  Room room;
  String message;
  Firestore _store = Firestore.instance;

  Notice(DocumentSnapshot doc) {
    this.type = doc['type'];
    this.data = doc['data'];
    this.createdAt = format(doc['createdAt'].toDate(), locale: 'ja');
    this.message = _typeParser(doc['type']);
    this._senderID = doc['senderID'];
  }

  String _typeParser(String type) {
    switch (type) {
      case 'add room':
        return 'トークルームを作成しました';
      default:
        return '';
    }
  }

  Future<User> _fetchUserFromFirebase({String uid}) async {
    final document = _store.collection('users').document(uid);
    final doc = await document.get();
    final user = User(
      uid: doc.documentID,
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      isTeacher: doc['isTeacher'],
      createdAt: doc['createdAt'],
      blockedUserID: doc['blockedUserID'],
    );
    return user;
  }

  Future<void> fetchSender() async {
    final sender = await _fetchUserFromFirebase(uid: this._senderID);
    this.sender = sender;
  }
}
