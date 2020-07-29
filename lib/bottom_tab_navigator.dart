import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'presentation/chat/chat_page.dart';
import 'presentation/home/home_page.dart';
import 'presentation/notice_list/notice_list_page.dart';
import 'presentation/setting/setting_page.dart';

class BottomTabNavigator extends StatefulWidget {
  @override
  _BottomTabNavigator createState() => _BottomTabNavigator();
}

class _BottomTabNavigator extends State<BottomTabNavigator> {
  int currentIndex = 0;

  final List<Widget> _widgetOptions = [
    Home(),
    Chat(),
    NoticeList(),
    Setting(),
  ];

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
                title: Text('ホーム'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                title: Text('チャット'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                title: Text('通知'),
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
        ],
      ),
    );
  }
}
