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
  bool isRead;
  FirebaseFirestore _store = FirebaseFirestore.instance;

  Notice(DocumentSnapshot doc) {
    this.type = doc.data()['type'];
    this.data = doc.data()['data'];
    this.createdAt = format(doc.data()['createdAt'].toDate(), locale: 'ja');
    this.message = _typeParser(doc.data()['type']);
    this._senderID = doc.data()['senderID'];
    this.isRead = doc.data()['isRead'];
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
    final document = _store.collection('users').doc(uid);
    final doc = await document.get();
    final user = User(
      uid: doc.id,
      displayName: doc.data()['displayName'],
      photoURL: doc.data()['photoURL'],
      isTeacher: doc.data()['isTeacher'],
      createdAt: doc.data()['createdAt'],
      blockedUserID: doc.data()['blockedUserID'],
    );
    return user;
  }

  Future<void> fetchSender() async {
    final sender = await _fetchUserFromFirebase(uid: this._senderID);
    this.sender = sender;
  }
}
