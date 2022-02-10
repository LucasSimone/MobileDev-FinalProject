import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'model/user.dart';
import 'themes/colour.dart';
import 'model/post.dart';
import 'makepost.dart';
import 'utils.dart';
import 'package:provider/provider.dart';
import 'animation/animationimage.dart';
import 'tabpage.dart';
import 'statistics.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final User user;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CurrentUser bloC;

  @override
  Widget build(BuildContext context) {
    bloC = context.watch<CurrentUser>();

    String birthday = toDateString(widget.user.dob);
    return Scaffold(
      backgroundColor: myInt == 0 ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: redcol,
        title: Text(widget.title),
        actions: [
          widget.user == bloC.currentUser
              ? IconButton(
                  icon: Icon(Icons.insert_chart),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsTable(
                            user: bloC.currentUser,
                          ),
                        ));
                  })
              : Container()
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          color: secondarycol,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //profile avatar
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.amber[100],
                child: CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(widget.user.avatar)),
              ),
              Container(
                //username
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  widget.user.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              Container(
                //username
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  birthday,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),

              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future: getPosts(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      //loading bar while loading users
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) =>
                                  _buildPost(context, document))
                              .toList(),
                        );
                      }
                    }),
              )
            ],
          )),
      floatingActionButton: (bloC.currentUser.username == widget.user.username)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakePost(
                        title: "Upload Post",
                        user: bloC.currentUser,
                      ),
                    )).then((value) => setState(() {}));
              },
              tooltip: 'Make Post',
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }

  Widget _buildPost(BuildContext context, DocumentSnapshot postData) {
    //build user tab for a user
    final post = Post.fromMap(postData.data(), reference: postData.reference);
    return Card(
        color: myInt == 0 ? Colors.white : Colors.black,
        child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                post.isanimated
                    ? Center(
                        child: Animated(
                          ispreview: false,
                          sublink: post.subimage,
                          mainlink: post.mainimage,
                          ratioxinitial: post.ratios[0],
                          ratioyinitial: post.ratios[1],
                          ratioxfinal: post.ratios[2],
                          ratioyfinal: post.ratios[3],
                          ratiowinitial: post.ratios[4],
                          ratiohinitial: post.ratios[5],
                          ratiowfinal: post.ratios[6],
                          ratiohfinal: post.ratios[7],
                          curvesize: post.curvesize,
                          curvex: post.curvex,
                          curvey: post.curvey,
                          height: MediaQuery.of(context).size.width * 0.45,
                          width: MediaQuery.of(context).size.width * 0.45,
                        ),
                      )
                    : Image(
                        image: NetworkImage(post.mainimage),
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.width * 0.45,
                      ),
                Expanded(
                    child: SingleChildScrollView(
                        child: Text(post.text,
                            style: TextStyle(
                              color: myInt == 0 ? Colors.black : Colors.white,
                            )))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text((post.likers).length.toString(),
                          style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white,
                          )),
                      IconButton(
                          icon: post.likers.contains(bloC.currentUser.id)
                              ? Icon(
                                  Icons.favorite_sharp,
                                  color:
                                      myInt == 0 ? Colors.black : Colors.white,
                                )
                              : Icon(
                                  Icons.favorite_border_sharp,
                                  color:
                                      myInt == 0 ? Colors.black : Colors.white,
                                ),
                          onPressed: () {
                            setState(() {
                              List likers = post.likers;
                              if (likers.contains(bloC.currentUser.id)) {
                                likers.remove(bloC.currentUser.id);
                                updateLikers(post.id, likers);
                              } else {
                                likers.add(bloC.currentUser.id);
                                updateLikers(post.id, likers);
                              }
                            });
                          })
                    ]),
                    Text(
                      toDateString(post.dateposted),
                      style: TextStyle(
                        color: myInt == 0 ? Colors.black : Colors.white,
                      ),
                    ),
                    bloC.currentUser.id == widget.user.id
                        ? IconButton(
                            icon: Icon(
                              Icons.delete_rounded,
                              color: myInt == 0 ? Colors.black : Colors.white,
                            ),
                            onPressed: () {
                              showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          Text("Delete Post?"), //GetDataTable
                                      actions: [
                                        FlatButton(
                                          child: Text("Delete"),
                                          onPressed: () {
                                            setState(() {
                                              post.reference.delete().then(
                                                  (value) =>
                                                      Navigator.of(context)
                                                          .pop());
                                            });
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Back"),
                                          onPressed: () {
                                            print("back");
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            })
                        : Container(),
                  ],
                )
              ],
            )));
  }

//get user posts collections sorted by date
  Future<QuerySnapshot> getPosts() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('userposts')
        .orderBy("dateposted", descending: true)
        .get();
  }

  //update likers of a post
  Future<void> updateLikers(String postid, List newlikers) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.id)
        .collection('userposts')
        .doc(postid)
        .update({"likers": newlikers});
  }
}
