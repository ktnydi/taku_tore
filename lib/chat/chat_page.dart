import 'package:flutter/material.dart';
import '../chat_room/chat_room_page.dart';

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatList(),
    );
  }
}

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ChatCell();
      },
      itemCount: 3,
    );
  }
}

class ChatCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
      leading: CircleAvatar(
        child: Text('ボブ'[0]),
        radius: 25,
      ),
      title: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'ボブ',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 0,
            child: Text(
              '11:02',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'ここにテキストが入ります。ここにテキストが入ります。ここにテキストが入ります。',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // TODO: Add Navigation.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChatRoom(),
          ),
        );
      },
    );
  }
}
