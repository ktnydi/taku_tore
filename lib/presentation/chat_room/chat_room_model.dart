import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    final currentUser = await FirebaseAuth.instance.currentUser();
    final document =
        Firestore.instance.collection('users').document(currentUser.uid);
    final doc = await document.get();

    final isBlocking = doc['blockedUserID'].contains(this.user.uid);
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
    final currentUser = await FirebaseAuth.instance.currentUser();

    if (this.room.lastMessageFromUid == currentUser.uid) {
      return;
    }

    final document = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(this.room.documentId);

    document.updateData(
      {
        'numNewMessage': 0,
      },
    );
  }

  Future fetchExtraMessage() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final collection = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(this.room.documentId)
        .collection('messages');

    final query = collection
        .orderBy('createdAt', descending: true)
        .startAfterDocument(this.start)
        .limit(30);

    final docs = (await query.getDocuments()).documents;

    if (docs.isEmpty) {
      this.showAllMessage = true;
      return;
    }

    this.start = docs.isNotEmpty ? docs[docs.length - 1] : null;

    notifyListeners();
  }

  Future addMessageWithTransition() async {
    final currentUser = await FirebaseAuth.instance.currentUser();

    final roomRef = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('rooms')
        .document(room.documentId);

    final messageRef = roomRef.collection('messages').document();

    final from = currentUser.uid;
    final to = this.room.student.uid == currentUser.uid
        ? this.room.teacher.uid
        : this.room.student.uid;

    final batch = Firestore.instance.batch();

    batch.setData(
      roomRef,
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': this.messageController.text,
        'lastMessageFromUid': currentUser.uid,
      },
      merge: true,
    );

    batch.setData(
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
