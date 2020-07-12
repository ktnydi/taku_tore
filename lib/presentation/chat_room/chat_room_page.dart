import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/message.dart';
import '../../domain/room.dart';
import '../../domain/user.dart';
import '../../user_model.dart';
import 'chat_room_model.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({@required this.user, @required this.room});

  final User user;
  final Room room;
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomModel>(
      create: (_) => ChatRoomModel()..fetchMessagesAsStream(room: widget.room),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                child: Consumer2<UserModel, ChatRoomModel>(
                  builder: (_, um, cm, __) {
                    return Stack(
                      children: <Widget>[
                        StreamBuilder(
                          stream: cm.messagesAsStream,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return Container();
                            }

                            final List<Message> messageList = snapshot.data;

                            final messages = messageList.reversed.map(
                              (message) {
                                if (um.user.uid == message.from.uid) {
                                  return ChatRoomCellRight(
                                    message: message,
                                  );
                                } else {
                                  return ChatRoomCellLeft(
                                    toUser: widget.user,
                                    message: message,
                                  );
                                }
                              },
                            ).toList();

                            return ListView.separated(
                              controller: cm.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) => messages[index],
                              itemCount: messages.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 15),
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                            );
                          },
                        ),
                        cm.isLoading
                            ? Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  },
                ),
              ),
              SendMessageField(
                room: widget.room,
              ),
            ],
          ),
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
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
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
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
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
    );
  }
}

class SendMessageField extends StatefulWidget {
  SendMessageField({
    @required this.room,
  });

  final Room room;
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Consumer<ChatRoomModel>(
                builder: (_, model, __) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'メッセージを入力...',
                            ),
                            minLines: 1,
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              model.scrollToBottom();
                              if (value.length == 0) {
                                setState(() => isDisabled = true);
                                return;
                              }

                              setState(() => isDisabled = false);
                            },
                            onTap: () async {
                              await model.scrollToBottom();
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      ButtonTheme(
                        minWidth: 0,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: FlatButton(
                          disabledTextColor: Colors.black45,
                          textColor: Colors.orange,
                          child: Icon(Icons.send),
                          onPressed: !isDisabled
                              ? () async {
                                  if (_messageController.text.trim().isEmpty) {
                                    return;
                                  }
                                  model.room = widget.room;
                                  try {
                                    await model.addMessageWithTransition(
                                        text: _messageController.text);
                                    _messageController.text = '';
                                    await model.scrollToBottom();
                                    setState(() => isDisabled = true);
                                  } catch (error) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(error.toString()),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('OK'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
