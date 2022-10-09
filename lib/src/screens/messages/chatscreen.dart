import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:squirrel_main/helperfunctions/sharedpref_helper.dart';
import 'package:squirrel_main/services/database.dart';

class ChatsScreen extends StatefulWidget {
  final String chatWithUsername, name;

  ChatsScreen(this.chatWithUsername, this.name);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatsScreen> {
  late String chatRoomId, messageId = '';
  TextEditingController messageTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatRoomId = _getChatRoomIdByUsernames(
      widget.chatWithUsername,
      SharedPreferenceHelper().userName,
    );
  }

  // Widget chatMessages() {
  //   return StreamBuilder(
  //     stream: messageStream,
  //     builder: (context, snapshot) {
  //       return snapshot.hasData
  //           ? ListView.builder(
  //               itemCount: snapshot.data.docs.length,
  //               itemBuilder: (context, index) {
  //                 DocumentSnapshot ds = snapshot.data.docs[index];
  //                 return Text(ds["message"]);
  //               })
  //           : Center(child: CircularProgressIndicator());
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.chatWithUsername),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<dynamic>(
                    stream: DatabaseMethods().getChatRoomMessages(chatRoomId),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 5, top: 16),
                        itemCount: snapshot.data.docs?.length ?? 0,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return _chatMessageTile(
                            ds['message'],
                            SharedPreferenceHelper().userName == ds['sendBy'],
                          );
                        },
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.attach_file),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20 * 0.75),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20 / 4,
                            ),
                            Expanded(
                              child: TextField(
                                controller: messageTextEditingController,
                                onChanged: (value) {
                                  _addMessage(false);
                                },
                                decoration: InputDecoration(
                                    hintText: 'Send a message',
                                    border: InputBorder.none),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _addMessage(true);
                              },
                              child: Icon(
                                Icons.send,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color
                                        ?.withOpacity(0.64) ??
                                    Colors.red,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0),
            ),
            color: Colors.blue,
          ),
          padding: EdgeInsets.all(16),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  _getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  _addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": SharedPreferenceHelper().userName,
        "ts": lastMessageTs,
        "imgUrl": SharedPreferenceHelper().userProfileUrl
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": SharedPreferenceHelper().userName
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          // remove the text in the message input field
          messageTextEditingController.text = '';

          // make the message id blank to get regenerated on next message send
          messageId = '';
        }
      });
    }
  }
}
