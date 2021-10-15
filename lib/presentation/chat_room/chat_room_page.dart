import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat_info/chat_info_page.dart';
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
  String getDate(Timestamp ts) {
    final date = ts != null ? ts.toDate() : DateTime.now();
    return '${date.month}/${date.day} ${date.hour}:${date.minute}';
  }

  bool isLastMessageRight(
    int index,
    UserModel model,
    List<DocumentSnapshot> documents,
  ) {
    if (index == 0) {
      return false;
    }

    final beforeDate = getDate(
        (documents[index - 1].data() as Map<String, dynamic>)['createdAt']);
    final currentDate =
        getDate((documents[index].data() as Map<String, dynamic>)['createdAt']);
    return (documents[index - 1].data() as Map<String, dynamic>)['fromUid'] ==
            model.user.uid &&
        beforeDate == currentDate;
  }

  bool isLastMessageLeft(
    int index,
    UserModel model,
    List<DocumentSnapshot> documents,
  ) {
    if (index == 0) {
      return false;
    }

    final beforeDate = getDate(
        (documents[index - 1].data() as Map<String, dynamic>)['createdAt']);
    final currentDate =
        getDate((documents[index].data() as Map<String, dynamic>)['createdAt']);
    return (documents[index - 1].data() as Map<String, dynamic>)['fromUid'] !=
            model.user.uid &&
        beforeDate == currentDate;
  }

  List<Widget> _buildMessages({
    Widget child,
    List<DocumentSnapshot> documents,
    UserModel model,
  }) {
    List<Widget> messages = [];
    documents.asMap().forEach(
      (index, doc) {
        final map = doc.data() as Map<String, dynamic>;
        final message = Message(
          fromUid: map['fromUid'],
          toUid: map['toUid'],
          content: map['content'],
          createdAt: map['createdAt'],
        );

        final isLastMessageRight = this.isLastMessageRight(
          index,
          model,
          documents,
        );
        final isLastMessageLeft = this.isLastMessageLeft(
          index,
          model,
          documents,
        );

        if (model.user.uid == message.fromUid) {
          messages = [
            ...messages,
            ChatRoomCellRight(
              message: message,
              isLastMessageRight: isLastMessageRight,
            ),
          ];
        } else {
          messages = [
            ...messages,
            ChatRoomCellLeft(
              toUser: widget.user,
              message: message,
              isLastMessageLeft: isLastMessageLeft,
            ),
          ];
        }
      },
    );
    return <Widget>[...messages, child ?? Container()];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatRoomModel>(
      create: (_) => ChatRoomModel(
        room: widget.room,
        user: widget.user,
      )
        ..checkBlocked()
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
            actions: <Widget>[
              Consumer<ChatRoomModel>(
                builder: (_, model, __) {
                  return IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () async {
                      // TODO: Navigation to ChatInfo
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (BuildContext context) => ChatInfo(
                            user: widget.user,
                            room: widget.room,
                          ),
                        ),
                      );
                      model.checkBlocked();
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Consumer2<UserModel, ChatRoomModel>(
                  builder: (_, um, cm, __) {
                    Query query = context.read<UserModel>().user.uid ==
                            widget.room.teacher.uid
                        ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(um.user.uid)
                            .collection('teachers')
                            .doc(um.user.uid)
                            .collection('rooms')
                            .doc(widget.room.documentId)
                            .collection('messages')
                            .orderBy('createdAt', descending: true)
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(um.user.uid)
                            .collection('rooms')
                            .doc(widget.room.documentId)
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
                        final List<DocumentSnapshot> documents = docs.docs;

                        if (documents.isNotEmpty && documents.length >= 30) {
                          cm.start = documents[documents.length - 1];
                        } else {
                          cm.showAllMessage = true;
                        }

                        return ListView(
                          controller: cm.scrollController,
                          padding: EdgeInsets.only(bottom: 30, top: 15),
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
  ChatRoomCellRight({@required this.message, this.isLastMessageRight});

  final Message message;
  final bool isLastMessageRight;

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
    return Container(
      margin: EdgeInsets.only(
        bottom: !isLastMessageRight ? 15 : 0,
        left: 15,
        right: 15,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xff203152),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(18),
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
            SizedBox(height: 5),
            !isLastMessageRight
                ? Text(
                    createdAtAsString(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  )
                : SizedBox(),
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
    @required this.isLastMessageLeft,
  });

  final Message message;
  final User toUser;
  final bool isLastMessageLeft;

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
    return Container(
      margin: EdgeInsets.only(
        bottom: !isLastMessageLeft ? 15 : 0,
        left: 15,
        right: 15,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            !isLastMessageLeft
                ? Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(toUser.photoURL),
                        radius: 18,
                      ),
                      SizedBox(height: 5),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : SizedBox(width: 36),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xffeff0f1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  !isLastMessageLeft
                      ? Text(
                          createdAtAsString(message.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ],
        ),
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
              TextButton(
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
    return Consumer<ChatRoomModel>(
      builder: (_, model, __) {
        if (model.isBlocked) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  color: Colors.black12,
                ),
              ),
              color: Colors.white,
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '現在、メッセージを送信できません',
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: Colors.black12,
              ),
            ),
            color: Colors.white,
          ),
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: TextField(
                      controller: model.messageController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        border: InputBorder.none,
                        hintText: 'メッセージを入力...',
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => model.message = value,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                ButtonTheme(
                  minWidth: 0,
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: TextButton(
                    child: Icon(
                      Icons.send,
                      size: 30,
                    ),
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: model.message.isNotEmpty
                        ? () async {
                            await this._submit(context, model: model);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
