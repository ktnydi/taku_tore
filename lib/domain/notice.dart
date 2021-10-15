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

  Notice(Map<String, dynamic> map)
      : this.type = map['type'],
        this.data = map['data'],
        this.createdAt = format(map['createdAt'].toDate(), locale: 'ja'),
        this.message = map['type'],
        this._senderID = map['senderID'],
        this.isRead = map['isRead'];

  Future<User> _fetchUserFromFirebase({String uid}) async {
    final document = _store.collection('users').doc(uid);
    final doc = await document.get();
    final map = doc.data();
    final user = User(
      uid: doc.id,
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      isTeacher: map['isTeacher'],
      createdAt: map['createdAt'],
      blockedUserID: map['blockedUserID'],
    );
    return user;
  }

  Future<void> fetchSender() async {
    final sender = await _fetchUserFromFirebase(uid: this._senderID);
    this.sender = sender;
  }
}
