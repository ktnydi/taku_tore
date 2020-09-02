import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';

class ChatRoomModel extends ChangeNotifier {
  DocumentSnapshot start;
  Room room;
  User user;
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  String _message = '';
  bool isFetchingMessage = false;
  bool showAllMessage = false;
  bool isBlocked = false;
  bool isLoading = false;

  ChatRoomModel({this.room, this.user});

  @override
  void dispose() {
    this.scrollController.dispose();
    this.messageController.dispose();

    super.dispose();
  }

  void beginLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future checkBlocked() async {
    beginLoading();

    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final document =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final doc = await document.get();

    final isBlocking = doc.data()['blockedUserID'].contains(this.user.uid);
    final isBlocked = this.user.blockedUserID.contains(currentUser.uid);

    this.isBlocked = isBlocking || isBlocked;

    endLoading();
  }

  void scrollListener() {
    scrollController.addListener(
      () async {
        final currentScrollPosition = this.scrollController.offset;
        final maxScrollExtent = this.scrollController.position.maxScrollExtent;

        if (!this.showAllMessage && currentScrollPosition == maxScrollExtent) {
          beginFetching();

          await fetchExtraMessage();

          endFetching();
        }
      },
    );
  }

  void beginFetching() {
    isFetchingMessage = true;
    notifyListeners();
  }

  void endFetching() {
    isFetchingMessage = false;
    notifyListeners();
  }

  String get message => this._message;

  set message(String value) {
    this._message = value;
    notifyListeners();
  }

  Future readMessage() async {
    if (!this.room.hasNewMessage) return;

    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (this.room.lastMessageFromUid == currentUser.uid) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final numNotices = userDoc.data()['numNotices'];

    final document = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .doc(this.room.documentId);

    final numNewMessage = (await document.get()).data()['numNewMessage'];

    final latestNumNotices = numNotices - numNewMessage;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update(
      {
        'numNotices': latestNumNotices,
      },
    );

    FlutterAppBadger.updateBadgeCount(latestNumNotices);

    document.update(
      {
        'numNewMessage': 0,
      },
    );
  }

  Future fetchExtraMessage() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .doc(this.room.documentId)
        .collection('messages');

    final query = collection
        .orderBy('createdAt', descending: true)
        .startAfterDocument(this.start)
        .limit(30);

    final docs = (await query.get()).docs;

    if (docs.isEmpty) {
      this.showAllMessage = true;
      return;
    }

    this.start = docs.isNotEmpty ? docs[docs.length - 1] : null;

    notifyListeners();
  }

  Future addMessageWithTransition() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    final roomRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .doc(room.documentId);

    final messageRef = roomRef.collection('messages').doc();

    final from = currentUser.uid;
    final to = this.room.student.uid == currentUser.uid
        ? this.room.teacher.uid
        : this.room.student.uid;

    final batch = FirebaseFirestore.instance.batch();

    batch.set(
      roomRef,
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': this.messageController.text,
        'lastMessageFromUid': currentUser.uid,
      },
      SetOptions(
        merge: true,
      ),
    );

    batch.set(
      messageRef,
      {
        'fromUid': from,
        'toUid': to,
        'content': this.messageController.text,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    batch.commit();
  }
}
