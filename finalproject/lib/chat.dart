import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/user.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  //Stream of all of the chats
  Stream<QuerySnapshot> chats;

  //Chat bar controller
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages(myName) {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  //Return custom message tile from the stream
                  return MessageTile(
                    message: snapshot.data.documents[index].data()["message"],
                    sendByMe: myName ==
                        snapshot.data.documents[index].data()["sendBy"],
                  );
                })
            : Container();
      },
    );
  }

  //Add a message to the chat and to the firestore
  addMessage(myName) {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      //Add to FireStore
      UserModel().addMessage(widget.chatRoomId, chatMessageMap);

      //Reset the chat box
      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  //Create the inital stream of chats
  @override
  void initState() {
    UserModel().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CurrentUser bloC = context.watch<CurrentUser>();

    return Scaffold(
      //Set the appbar to the particpant in the chat name
      appBar: AppBar(
        title: Text(widget.chatRoomId
            .replaceAll(bloC.currentUser.username, "")
            .replaceAll("_", "")),
      ),
      body: Container(
        child: Stack(
          children: [
            //Stream builder widget
            chatMessages(bloC.currentUser.username),

            //Container to hold where the user enters text
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: Colors.red[200],
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      decoration: InputDecoration(
                          hintText: "Message ...",
                          hintStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage(bloC.currentUser.username);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Tile that represents a message
class MessageTile extends StatelessWidget {
  final String message;

  //Boolean to check if the current user that sent the message is yourself
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      //Padding to determine position of message tile depending on who sent it
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        //Margin to determine position of message tile depending on who sent it
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
          //Border Radius to create a nice shape for the MessageTiles
          //found these numbers for the BorderRadius online
          borderRadius: sendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
          color: sendByMe ? Colors.lightBlueAccent : Colors.lightGreenAccent,
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300)),
      ),
    );
  }
}
