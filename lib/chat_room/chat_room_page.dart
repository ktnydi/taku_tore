import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../message.dart';
import '../room.dart';
import '../user.dart';
import '../user_model.dart';
import 'chat_room_model.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({@required this.user, @required this.room});

  final User user;
  final Room room;
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomModel>(
      create: (_) => ChatRoomModel()..fetchMessagesAsStream(room: widget.room),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Consumer2<UserModel, ChatRoomModel>(
                  builder: (_, userModel, chatRoomModel, __) {
                    return StreamBuilder(
                      stream: chatRoomModel.messagesAsStream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Container();
                        }

                        final messages = snapshot.data.map(
                          (message) {
                            if (userModel.user.uid == message.from.uid) {
                              return ChatRoomCellRight(
                                message: message,
                              );
                            } else {
                              return ChatRoomCellLeft(
                                  toUser: widget.user, message: message);
                            }
                          },
                        ).toList();

                        return Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            controller: controller,
                            reverse: true,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => messages[index],
                            itemCount: messages.length,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SendMessageField(
              room: widget.room,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomCellRight extends StatelessWidget {
  ChatRoomCellRight({@required this.message});

  final Message message;

  String createdAtAsString(Timestamp ts) {
    final DateTime date = ts.toDate();
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour;
    final minute = date.minute;
    return '$year/$month/$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              createdAtAsString(message.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 5),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomCellLeft extends StatelessWidget {
  ChatRoomCellLeft({
    @required this.message,
    @required this.toUser,
  });

  final Message message;
  final User toUser;

  String createdAtAsString(Timestamp ts) {
    final DateTime date = ts.toDate();
    final year = date.year;
    final month = date.month;
    final day = date.day;
    final hour = date.hour;
    final minute = date.minute;
    return '$year/$month/$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(toUser.photoURL),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    createdAtAsString(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendMessageField extends StatefulWidget {
  SendMessageField({
    @required this.room,
    @required this.controller,
  });

  final Room room;
  final ScrollController controller;
  @override
  _SendMessageFieldState createState() => _SendMessageFieldState();
}

class _SendMessageFieldState extends State<SendMessageField>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool isDisabled = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'メッセージを入力...',
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  if (value.length == 0) {
                    setState(() => isDisabled = true);
                    return;
                  }

                  setState(() => isDisabled = false);
                },
              ),
            ),
            Consumer<ChatRoomModel>(
              builder: (_, model, __) {
                return IconButton(
                  disabledColor: Colors.black45,
                  color: Colors.orange,
                  icon: Icon(Icons.send),
                  onPressed: !isDisabled
                      ? () async {
                          model.room = widget.room;
                          try {
                            await model.addMessageWithTransition(
                                text: _messageController.text);
                            _messageController.text = '';
                            setState(() => isDisabled = true);
                            widget.controller.animateTo(
                              0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          } catch (error) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(error.toString()),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
