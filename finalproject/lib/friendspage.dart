import 'package:finalproject/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'model/user.dart';
import 'themes/colour.dart';
import 'package:provider/provider.dart';
import 'profile.dart';
import 'utils.dart';
import 'tabpage.dart';

class FriendPage extends StatefulWidget {
  FriendPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  @override
  Widget build(BuildContext context) {
    final CurrentUser bloC = context.watch<CurrentUser>();

    return Container(
      color: myInt == 0 ? Colors.white : Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(bloC.currentUser.id)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var userDocument = snapshot.data;
                  List friends = [];
                  if (userDocument.data().containsKey("friends")) {
                    friends = userDocument["friends"];
                  } else {
                    return Center(
                      child: Text(
                        "You have no friends added :(",
                        style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white),
                      ),
                    );
                  }
                  return FutureBuilder(
                      future: getUserList(friends),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.none &&
                                !snap.hasData ||
                            snap.data == null) {
                          return Container();
                        } else {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            shrinkWrap: true,
                            itemCount: snap.data.length,
                            itemBuilder: (context, index) {
                              User u = snap.data[index];
                              return _buildUser(
                                  context, u, bloC.currentUser, false);
                            },
                          );
                        }
                      });
                }),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Pending Requests",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: myInt == 0 ? Colors.black : Colors.white),
            ),
            SizedBox(
              height: 30.0,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(bloC.currentUser.id)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var userDocument = snapshot.data;
                  List friends = [];
                  if (userDocument.data().containsKey("friendRequests")) {
                    friends = userDocument["friendRequests"];
                  } else {
                    return Center(
                      child: Text(
                        "You have no pending friend requests :(",
                        style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white),
                      ),
                    );
                  }
                  return FutureBuilder(
                      future: getUserList(friends),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.none &&
                                !snap.hasData ||
                            snap.data == null) {
                          return Container();
                        } else {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            shrinkWrap: true,
                            itemCount: snap.data.length,
                            itemBuilder: (context, index) {
                              User u = snap.data[index];
                              return _buildUser(
                                  context, u, bloC.currentUser, true);
                            },
                          );
                        }
                      });
                }),
          ],
        ),
      ),
    );
  }

  Future<List<User>> getUserList(List userNames) async {
    List<User> userList = [];
    for (var name in userNames) {
      userList.add(await UserModel().getUser(name));
    }

    return userList;
  }

  Widget _buildUser(
      BuildContext context, User user, User currentUser, bool requests) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(5),
        color: secondarycol,
        child: Row(
          children: [
            //avatar image
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.amber[100],
              child: CircleAvatar(
                  radius: 31, backgroundImage: NetworkImage(user.avatar)),
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //username
                          Text(
                            user.username,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23),
                          ),
                          Text(""),
                          //birthday
                          Text(
                            toDateString(user.dob),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          )
                        ]))),
            //profile button
            IconButton(
                onPressed: () {
                  final snackBar = SnackBar(content: Text(user.username));
                  Scaffold.of(context).showSnackBar(snackBar);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(user: user, title: "Profile"),
                    ),
                  );
                  print(widget.title);
                },
                icon: Icon(Icons.person)),
            requests
                ? IconButton(
                    onPressed: () {
                      print("Enter add user");
                      currentUser.friends.add(user.username);
                      currentUser.friendRequests.remove(user.username);

                      user.friends.add(currentUser.username);
                      UserModel().updateFriends(user.reference, user.friends);
                      UserModel().updateFriendRequests(
                          user.reference, user.friendRequests);

                      UserModel().updateFriends(
                          currentUser.reference, currentUser.friends);
                      UserModel().updateFriendRequests(
                          currentUser.reference, currentUser.friendRequests);

                      print("Added user");

                      setState(() {});
                    },
                    icon: Icon(Icons.add))
                : IconButton(
                    onPressed: () {
                      sendMessage(user.username, currentUser.username);
                    },
                    icon: Icon(Icons.message))
          ],
        ));
  }

  Future<QuerySnapshot> getUsers() async {
    //get users collection
    return await FirebaseFirestore.instance.collection('users').get();
  }

  Future<QuerySnapshot> getPosts() async {
    //get users collection
    return await FirebaseFirestore.instance.collection('posts').get();
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  // create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName, String myName) {
    List<String> users = [myName, userName];

    String chatRoomId = getChatRoomId(myName, userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    UserModel().addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  chatRoomId: chatRoomId,
                )));
  }
}
