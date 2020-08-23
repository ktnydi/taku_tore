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
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // TODO: Add a future for searching teacher.
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: Container(
            height: 50,
            child: TabBar(
              labelPadding: EdgeInsets.symmetric(horizontal: 0),
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black45,
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
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ChatList(tabName: 'teacher'),
          ChatList(tabName: 'student'),
        ],
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  ChatList({this.tabName});

  final String tabName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatModel>(
      create: (_) => ChatModel(tabName: this.tabName)
        ..fetchRooms()
        ..scrollListener(),
      child: Consumer2<UserModel, ChatModel>(
        builder: (_, um, cm, __) {
          if (cm.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final rooms =
              this.tabName == 'teacher' ? cm.teacherRooms : cm.studentRooms;

          if (rooms.isEmpty) {
            return Center(
              child: Text(
                'チャットルームはありません。',
              ),
            );
          }

          final listTiles = rooms.map(
            (room) {
              return um.user.uid == room.teacher.uid
                  ? ChatCell(user: room.student, room: room)
                  : ChatCell(user: room.teacher, room: room);
            },
          ).toList();
          return ListView.separated(
            controller:
                this.tabName == 'teacher' ? cm.teacherScroll : cm.studentScroll,
            physics: AlwaysScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(height: 0.5),
            itemBuilder: (context, index) {
              return listTiles[index];
            },
            itemCount: listTiles.length,
          );
        },
      ),
    );
  }
}

class ChatCell extends StatelessWidget {
  ChatCell({@required this.user, @required this.room});

  final User user;
  final Room room;
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (_, model, __) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          color: Colors.white,
          child: Row(
            children: <Widget>[
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
                        format(room.updatedAt.toDate(), locale: 'ja'),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${room.lastMessage}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Center(
                        child: room.numNewMessage > 0
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 24,
                                ),
                                child: Container(
                                  height: 24,
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${room.numNewMessage}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                  onTap: () async {
                    // TODO: Add Navigation.
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChatRoom(user: user, room: room),
                      ),
                    );
                    model.fetchRooms();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
