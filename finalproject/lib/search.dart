import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'tabpage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  CurrentUser bloC;
  String searchKey;
  Stream streamQuery;

  @override
  void initState() {
    //On load, have all the available users show up as potential
    //friends to add
    setState(() {
      streamQuery = UserModel()
          .users
          .where('username', isGreaterThanOrEqualTo: "")
          .where('username', isLessThan: "" + 'z')
          .snapshots();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bloC = context.watch<CurrentUser>();
    return Container(
      color: myInt == 0 ? Colors.white : Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                color: myInt == 0 ? Colors.white : Colors.grey,
                child: Row(
                  children: [
                    new Flexible(
                      child: TextField(
                        style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        //When text is entered remake the stream
                        onChanged: (value) {
                          setState(() {
                            searchKey = value;
                            //Remake stream
                            streamQuery = UserModel()
                                .users
                                .where('username',
                                    isGreaterThanOrEqualTo: searchKey)
                                .where('username', isLessThan: searchKey + 'z')
                                .snapshots();
                          });
                        },
                      ),
                    ),
                    Icon(Icons.search),
                  ],
                )),
            //build list of users that are being searched for from the stream
            StreamBuilder(
              stream: streamQuery,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      // child: CircularProgressIndicator(),
                      );
                } else {
                  return ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    children: snapshot.data.docs
                        .map<Widget>((DocumentSnapshot document) =>
                            _buildUser(context, document, bloC.currentUser))
                        .toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUser(
      BuildContext context, DocumentSnapshot userData, User current) {
    //build user tab for a user
    final user = User.fromMap(userData.data(), reference: userData.reference);
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(5),
        color: Colors.orange,
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
                        ]))),
            IconButton(
                onPressed: () {
                  //Default text to send
                  String textToSend =
                      "You have sent ${user.username} a friend request";

                  //Check conditions to see if a user can be added
                  if (user.friendRequests.contains(current.username)) {
                    textToSend =
                        "${user.username} already has a friend request from you";
                  } else if (bloC.currentUser.username == user.username) {
                    textToSend = "You can't add yourself as a friend.";
                  } else if (user.friends.contains(current.username) ||
                      current.friends.contains(user.username)) {
                    textToSend = "You already have ${user.username} added";
                  }
                  //If you already have a request from the user add them automatically
                  else if (current.friendRequests.contains(user.username)) {
                    textToSend =
                        "You already have a friend request from ${user.username}. Added friend!";
                    current.friends.add(user.username);
                    current.friendRequests.remove(user.username);

                    user.friends.add(current.username);
                    UserModel().updateFriends(user.reference, user.friends);
                    UserModel().updateFriendRequests(
                        user.reference, user.friendRequests);

                    UserModel()
                        .updateFriends(current.reference, current.friends);
                    UserModel().updateFriendRequests(
                        current.reference, current.friendRequests);
                  } else {
                    user.friendRequests.add(current.username);
                    UserModel().updateFriendRequests(
                        userData.reference, user.friendRequests);
                  }

                  //Send the snackbar with the text from above
                  final snackBar = SnackBar(content: Text(textToSend));
                  Scaffold.of(context).showSnackBar(snackBar);
                },
                icon: Icon(Icons.person_add))
          ],
        ));
  }
}
