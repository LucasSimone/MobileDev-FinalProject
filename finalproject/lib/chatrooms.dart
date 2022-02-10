import 'package:finalproject/model/user_model.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'model/user.dart';
import 'tabpage.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({Key key, this.currentUser}) : super(key: key);
  final User currentUser;

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  //Stream of all current chatrooms for the user
  Stream chatRooms;

  Widget chatRoomsList(myName) {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  //Create tile for each chatroom
                  return ChatRoomsTile(
                    //Remove the extra information from the chat room data so that we can grab the username
                    userName: snapshot.data.documents[index]
                        .data()['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(myName, ""),
                    chatRoomId:
                        snapshot.data.documents[index].data()["chatRoomId"],
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats(widget.currentUser.username);
    super.initState();
  }

  getUserInfogetChats(name) async {
    //Create stream for chats from the firestore
    UserModel().getUserChats(name).then((snapshots) {
      if (this.mounted) {
        setState(() {
          chatRooms = snapshots;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: myInt == 0 ? Colors.white : Colors.black,
      child: chatRoomsList(widget.currentUser.username),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({this.userName, @required this.chatRoomId});

  //Create an avatar widget for the chatroom
  Widget avatarWidget() {
    return FutureBuilder(
      future: UserModel().getUser(userName),
      builder: (context, AsyncSnapshot<User> snapshot) {
        //If there is no data put a placeholder image
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          return CircleAvatar(
              backgroundImage:
                  NetworkImage("http://via.placeholder.com/350x150"));
        }

        //If the data is null put a placeholder image
        if (snapshot.data == null) {
          return CircleAvatar(
              backgroundImage:
                  NetworkImage("http://via.placeholder.com/350x150"));
        }

        //Return user avatar
        return CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data.avatar));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                    )));
      },
      child: Container(
        color: Colors.redAccent,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            //User Avatar
            Container(
              height: 30,
              width: 30,
              child: avatarWidget(),
            ),
            SizedBox(
              width: 12,
            ),
            //Add username to chatroom tile after the avatar
            Text(userName,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
