import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat_room/chat_room_page.dart';
import '../chat/chat_model.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';
import '../../user_model.dart';

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatModel>(
      create: (_) => ChatModel()..fetchRooms(),
      child: Scaffold(
        body: ChatList(),
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserModel, ChatModel>(
      builder: (_, userModel, chatModel, __) {
        if (chatModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatModel.rooms.isEmpty) {
          return Center(
            child: Text(
              '相談中の講師はありません。',
            ),
          );
        }

        final listTiles = chatModel.rooms.map(
          (room) {
            return userModel.user.uid == room.teacher.uid
                ? ChatCell(user: room.student, room: room)
                : ChatCell(user: room.teacher, room: room);
          },
        ).toList();
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) => listTiles[index],
          itemCount: listTiles.length,
        );
      },
    );
  }
}

class ChatCell extends StatelessWidget {
  ChatCell({@required this.user, @required this.room});

  final User user;
  final Room room;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(15),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL),
        backgroundColor: Colors.transparent,
        radius: 25,
      ),
      title: Text(
        user.displayName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // TODO: Add Navigation.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChatRoom(user: user, room: room),
          ),
        );
      },
    );
  }
}
