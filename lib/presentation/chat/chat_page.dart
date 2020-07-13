import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';
import '../chat_room/chat_room_page.dart';
import '../chat/chat_model.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';
import '../../user_model.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatModel>(
      create: (_) => ChatModel()..fetchRooms(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'TakuTore',
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
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: Container(
              padding: EdgeInsets.only(bottom: 15),
              height: 50,
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColor,
                ),
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('講師'),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('受講生'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Consumer<ChatModel>(
          builder: (_, model, __) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: <Widget>[
                ChatList(rooms: model.teacherRooms),
                ChatList(rooms: model.studentRooms),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  ChatList({@required this.rooms});

  final List<Room> rooms;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, model, __) {
        if (this.rooms.isEmpty) {
          return Center(
            child: Text(
              'チャットルームはありません。',
            ),
          );
        }

        final listTiles = this.rooms.map(
          (room) {
            return model.user.uid == room.teacher.uid
                ? ChatCell(user: room.student, room: room)
                : ChatCell(user: room.teacher, room: room);
          },
        ).toList();
        return ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) => listTiles[index],
          itemCount: listTiles.length,
          padding: EdgeInsets.all(15),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          Center(
            child: Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL),
                backgroundColor: Colors.transparent,
                radius: 28,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      user.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    format(room.updatedAt.toDate()),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
              subtitle: Text(
                room.lastMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              onTap: () {
                // TODO: Add Navigation.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ChatRoom(user: user, room: room),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
