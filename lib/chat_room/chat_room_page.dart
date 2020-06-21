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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomModel>(
      create: (_) => ChatRoomModel()..fetchMessages(room: widget.room),
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
                    if (chatRoomModel.messages.isEmpty) {
                      return Container();
                    }

                    final messages = chatRoomModel.messages.map(
                      (message) {
                        if (userModel.user.uid == message.from.uid) {
                          return ChatRoomCellRight(
                            message: message,
                          );
                        } else {
                          return ChatRoomCellLeft(message: message);
                        }
                      },
                    ).toList();

                    return ListView.builder(
                      itemBuilder: (context, index) => messages[index],
                      itemCount: messages.length,
                    );
                  },
                ),
              ),
            ),
            SendMessageField(room: widget.room),
          ],
        ),
      ),
    );
  }
}

class ChatRoomCellRight extends StatelessWidget {
  ChatRoomCellRight({@required this.message});

  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              '1日前',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
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
  ChatRoomCellLeft({@required this.message});

  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.only(right: 10),
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
            ),
            Text(
              '1日前',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendMessageField extends StatefulWidget {
  SendMessageField({@required this.room});

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
            Consumer<ChatRoomModel>(builder: (_, model, __) {
              return IconButton(
                disabledColor: Colors.black45,
                color: Colors.orange,
                icon: Icon(Icons.send),
                onPressed: !isDisabled
                    ? () async {
                        model.room = widget.room;
                        try {
                          await model.addMessage(text: _messageController.text);
                          _messageController.text = '';
                          model.fetchMessages(room: widget.room);
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
            }),
          ],
        ),
      ),
    );
  }
}
