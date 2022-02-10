import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/chatrooms.dart';
import 'package:finalproject/user_map.dart';
import 'package:flutter/material.dart';
import "friendspage.dart";
import "camera_page.dart";
import "login.dart";
import 'main.dart';
import 'search.dart';
import 'model/user.dart';
import 'model/db_utils.dart';
import 'package:provider/provider.dart';
import 'sharedpreferences.dart';
import 'userSettings.dart';
import 'profile.dart';
import 'change_profile_picture.dart';
import 'package:charts_flutter/flutter.dart' as charts;

var theSettings = SettingsModel();
int myInt = 0;

class TabPage extends StatefulWidget {
  TabPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  //ScaffoldKey - used to change scaffold
  final scaffoldKey = GlobalKey<ScaffoldState>();

  //A List that is used to store light and dark theme
  List<Color> colorList = <Color>[
    Colors.white,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CurrentUser bloC = context.watch<CurrentUser>();
    getReferenceNumber(bloC);
    List<Page> pages = <Page>[
      //To Add Widget page, add new Page element to list with
      //Title, icon, and a builder for the widget on that tab
      Page(
          title: "Friends",
          icon: Icons.person,
          builder: () {
            return FriendPage(
              title: "Friends",
            );
          }),
      Page(
          title: "Chats",
          icon: Icons.message_rounded,
          builder: () {
            return ChatRoom(
              currentUser: bloC.currentUser,
            );
          }),
      Page(
          title: "Add Friends",
          icon: Icons.person_add,
          builder: () {
            return SearchPage();
          }),
      Page(
          title: "Friend Map",
          icon: Icons.map,
          builder: () {
            return FriendMap(
              title: "Friend Map",
            );
          }),
      Page(
          title: "Camera",
          icon: Icons.photo_camera_rounded,
          builder: () {
            return CameraPage(
              title: "Example tab",
            );
          }),
    ];
    //tab controller
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        backgroundColor: myInt == 0
            ? colorList[0]
            : colorList[
                myInt], //Sets the background color according to if light theme is checked on or off
        key: scaffoldKey,
        appBar: AppBar(
          // leading: Image.asset(
          //   "assets/adgadg.png",
          //   // scale: 8.0,
          // ),
          leading: MaterialButton(
            child: Icon(
              Icons.home,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      title: "Profile",
                      user: bloC.currentUser,
                    ),
                  ));
            },
          ),
          title: Image.asset(
            "assets/baboingy-top-logo.png",
          ),
          bottom: buildTabBar(pages),
          actions: [
            IconButton(
              //Settings button at the top right
              icon: Icon(Icons.settings_rounded),
              onPressed: () {
                scaffoldKey.currentState
                    .openEndDrawer(); //When settings button is pressed, create the Drawer for the settings menu
              },
            ),
            IconButton(
              //Settings button at the top right
              icon: Icon(Icons.logout),
              onPressed: () {
                // bloC.setUser(null);
                Utils.saveUserLoggedInSharedPreference(false);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(title: 'Final Project')));
              },
            ),
          ],
        ),
        endDrawer: buildSettingsDrawer(context, bloC), //Create an end drawer
        body: buildTabBarView(pages),
      ),
    );
  }

  Widget buildSettingsDrawer(BuildContext context, CurrentUser bloC) {
    if (bloC.currentUser == null) {
      return Drawer();
    }

    return Drawer(
        child: Container(
            color: myInt == 0 ? Colors.white : Colors.black,
            child: ListView(children: <Widget>[
              //Have the header of the drawer be the user's name and their avatar
              DrawerHeader(
                  child: Row(children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text("${bloC.currentUser.username}'s Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: myInt == 0 ? Colors.black : Colors.white)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: MaterialButton(
                    onPressed: () {
                      //Change profile pic
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeProfilePic(
                              title: "Change Profile Picture",
                            ),
                          )).then((value) {
                        setState(() {});
                      });
                    },
                    child: CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(bloC.currentUser.avatar),
                        child: Icon(Icons.edit)),
                  ),
                ),
              ])),
              Column(
                children: [
                  ListTile(
                    //Create text and a switch that is either toggled: on/off and says either: light theme/dark theme
                    title: myInt == 0
                        ? Text("Light Theme",
                            style: TextStyle(
                                color:
                                    myInt == 0 ? Colors.black : Colors.white))
                        : Text("Dark Theme",
                            style: TextStyle(
                                color:
                                    myInt == 0 ? Colors.black : Colors.white)),
                    leading: Switch(
                      value: myInt == 0 ? false : true,
                      onChanged: (value) {
                        //When the button is clicked - update state
                        setState(() {
                          //print("${bloC.currentUser}");
                          theSettings
                              .getSettingById(bloC.currentUser.username)
                              .then((myUserSetting) {
                            if (value == true) {
                              //If switching from off to on
                              //Change theme of current user with updated theme 0/1
                              theSettings.updateSetting(userSettings(
                                  id: myUserSetting.id,
                                  account: myUserSetting.account,
                                  theme: 1,
                                  loginDate: myUserSetting.loginDate));
                              print("Saved setting: theme ${1}");
                              getReferenceNumber(
                                  bloC); //Update int that controls the themes
                            } else {
                              //If switching from on to off
                              //Change theme of current user with updated theme 0/1
                              theSettings.updateSetting(userSettings(
                                  id: myUserSetting.id,
                                  account: myUserSetting.account,
                                  theme: 0,
                                  loginDate: myUserSetting.loginDate));
                              print("Saved setting: theme ${0}");
                              getReferenceNumber(
                                  bloC); //Update int that controls the themes
                            }
                          });
                        });
                      },
                      activeTrackColor: Colors
                          .lightGreenAccent, //Sets colors for if the switch is toggled or not
                      activeColor: Colors.green,
                    ),
                  ),
                  //If it is an admin account, show statistical options. If it is not,
                  //Don't show the statistical option button
                  (bloC.currentUser.username != "admin")
                      ? Text("")
                      : Container(
                          padding: EdgeInsets.only(top: 20.0),
                          child: RaisedButton(
                            child: Text("View Statistics"),
                            onPressed: () {
                              _getStatisticalAlert(context);
                            },
                          ),
                        ),
                ],
              ),
            ])));
  }

  //Creates a dialog box, this will contain our charts
  void _getStatisticalAlert(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Friends Per User"),
            content: _buildChart(context),
            actions: [
              //Back button that will allow the user to close out
              //of the dialog box
              FlatButton(
                child: Text("Back"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  //Gets all users from the firebase database, converts it to a list
  Future<List<User>> getMyUsers() async {
    var asyncListOfUsers =
        await FirebaseFirestore.instance.collection('users').get();
    return asyncListOfUsers.docs
        .map(
          (mydoc) => User.fromMap(mydoc.data(), reference: mydoc.reference),
        )
        .toList();
  }

  //Builds a chart within a future builder
  FutureBuilder _buildChart(BuildContext context) {
    return FutureBuilder<List<User>>(
        future: getMyUsers(),
        //Initially, have an empty list
        initialData: List(),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          return charts.BarChart(
            [
              charts.Series<User, String>(
                id: "Friends",
                colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
                domainFn: (User myUser, _) => myUser.username,
                measureFn: (User myUser, _) => myUser.friends.length,
                data: snapshot.data,
              ),
            ],
            animate: true,
            vertical: false,
          );
        });
  }

  //This function awaits to get the userSettings from the database
  //If the int that controls the themes is different from the users desired theme
  //It will update the theme controller and update the state.
  Future<void> getReferenceNumber(CurrentUser bloC) async {
    if (bloC.currentUser == null) return;

    var e = await theSettings.getSettingById(bloC.currentUser.username);
    if (myInt != e.theme) {
      myInt = e.theme;
      setState(() {});
    }
  }
}

//page made up of tab title, tab icon and main tab widget
class Page {
  const Page({this.title, this.icon, this.builder});

  final String title;
  final IconData icon;
  final Function builder;
}

Widget buildTabBar(List<Page> options) {
  //build tab bar with widgets
  return TabBar(
    isScrollable: true,
    tabs: options.map<Widget>((Page option) {
      return Tab(
        text: option.title,
        icon: Icon(option.icon),
      );
    }).toList(),
  );
}

Widget buildTabBarView(var options) {
  //build views of tab widgets
  return TabBarView(
    children: options.map<Widget>((Page option) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          child: option.builder(),
        ),
      );
    }).toList(),
  );
}
