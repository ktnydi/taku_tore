import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takutore/atoms/badge.dart';
import 'presentation/chat/chat_page.dart';
import 'presentation/home/home_page.dart';
import 'presentation/notice_list/notice_list_page.dart';
import 'presentation/setting/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class BottomTabNavigator extends StatefulWidget {
  @override
  _BottomTabNavigator createState() => _BottomTabNavigator();
}

class _BottomTabNavigator extends State<BottomTabNavigator> {
  int currentIndex = 0;
  int noticeBadger = 0;
  int messageBadger = 0;
  int newTeacherNumMessage = 0;
  int newStudentNumMessage = 0;
  final _auth = auth.FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;

  final List<Widget> _widgetOptions = [
    Home(),
    Chat(),
    NoticeList(),
    Setting(),
  ];

  Future<void> _newMessageSnapshot() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    final studentRooms = _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('numNewMessage', isGreaterThan: 0);

    studentRooms.snapshots().listen(
      (snapshot) async {
        int messageBadger = 0;
        await Future.forEach(
          snapshot.docs,
          (DocumentSnapshot doc) async {
            final map = doc.data() as Map<String, dynamic>;
            messageBadger += map['numNewMessage'];
          },
        );
        setState(
          () {
            this.newStudentNumMessage = messageBadger;
            this.messageBadger =
                this.newStudentNumMessage + this.newTeacherNumMessage;
          },
        );
      },
    );

    final teacherRooms = _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('teachers')
        .doc(currentUser.uid)
        .collection('rooms')
        .where('numNewMessage', isGreaterThan: 0);

    teacherRooms.snapshots().listen(
      (snapshot) async {
        int messageBadger = 0;
        await Future.forEach(
          snapshot.docs,
          (DocumentSnapshot doc) async {
            final map = doc.data() as Map<String, dynamic>;
            messageBadger += map['numNewMessage'];
          },
        );
        setState(
          () {
            this.newTeacherNumMessage = messageBadger;
            this.messageBadger =
                this.newStudentNumMessage + this.newTeacherNumMessage;
          },
        );
      },
    );
  }

  Future<void> _newNoticeSnapshot() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    final notices = _store
        .collection('users')
        .doc(currentUser.uid)
        .collection('notices')
        .where('isRead', isEqualTo: false);

    notices.snapshots().listen(
      (snapshot) {
        setState(
          () {
            noticeBadger = snapshot.docs.length;
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    this._newMessageSnapshot();
    this._newNoticeSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(currentIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(height: 0.5),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0.0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  counter: this.messageBadger,
                  child: Icon(Icons.message),
                ),
                label: 'チャット',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  counter: this.noticeBadger,
                  child: Icon(Icons.notifications),
                ),
                label: '通知',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '設定',
              ),
            ],
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
