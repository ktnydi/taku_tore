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
  List<Widget> _buildMessages({
    Widget child,
    List<DocumentSnapshot> documents,
    UserModel model,
  }) {
    final messages = documents.map(
      (doc) {
        final message = Message(
          fromUid: doc['fromUid'],
          toUid: doc['toUid'],
          content: doc['content'],
          createdAt: doc['createdAt'],
        );

        if (model.user.uid == message.fromUid) {
          return Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: ChatRoomCellRight(
              message: message,
            ),
          );
        } else {
          return Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: ChatRoomCellLeft(
              toUser: widget.user,
              message: message,
            ),
          );
        }
      },
    ).toList();
    return <Widget>[...messages, child ?? Container()];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomModel>(
      create: (_) => ChatRoomModel(room: widget.room, user: widget.user)
        ..readMessage()
        ..scrollListener(),
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
                    Query query = Firestore.instance
                        .collection('users')
                        .document(um.user.uid)
                        .collection('rooms')
                        .document(widget.room.documentId)
                        .collection('messages')
                        .orderBy('createdAt', descending: true);
                    Stream<QuerySnapshot> watch;

                    if (cm.start != null) {
                      watch = query.endAtDocument(cm.start).snapshots();
                    } else {
                      watch = query.limit(30).snapshots();
                    }

                    return StreamBuilder(
                      stream: watch,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final QuerySnapshot docs = snapshot.data;
                        final List<DocumentSnapshot> documents = docs.documents;

                        if (documents.isNotEmpty) {
                          cm.start = documents[documents.length - 1];
                        }

                        return ListView(
                          controller: cm.scrollController,
                          reverse: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          children: _buildMessages(
                            child: Container(
                              height: !cm.showAllMessage ? 70 : 0,
                              child: Center(
                                child: cm.isFetchingMessage
                                    ? CircularProgressIndicator()
                                    : SizedBox(),
                              ),
                            ),
                            documents: documents,
                            model: um,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SendMessageField(),
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
    if (ts == null) {
      return 'loading...';
    }
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
    if (ts == null) {
      return 'Loading...';
    }

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

class SendMessageField extends StatelessWidget {
  Future _submit(BuildContext context, {ChatRoomModel model}) async {
    if (model.messageController.text.trim().isEmpty) {
      return;
    }
    try {
      await model.addMessageWithTransition();
      model.messageController.clear();
      await model.scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
                            controller: model.messageController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'メッセージを入力...',
                            ),
                            minLines: 1,
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
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
                          onPressed: () async {
                            await this._submit(context, model: model);
                          },
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
