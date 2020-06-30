import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './home/home_page.dart';
import './chat/chat_page.dart';
import './setting/setting_page.dart';

class BottomTabNavigator extends StatefulWidget {
  @override
  _BottomTabNavigator createState() => _BottomTabNavigator();
}

class _BottomTabNavigator extends State<BottomTabNavigator> {
  int currentIndex = 0;

  final List<Widget> _widgetOptions = [
    Home(),
    Chat(),
    Setting(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'TakuTore',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Column(
            children: <Widget>[
              Divider(height: 1),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // TODO: Add a future for searching teacher.
            },
            icon: Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Add a future for notification lists.
            },
            icon: Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('ホーム'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('チャット'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('設定'),
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
