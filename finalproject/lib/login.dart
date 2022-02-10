import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/model/user.dart';
import 'package:finalproject/model/user_model.dart';
import 'package:finalproject/signup.dart';
import 'package:finalproject/tabpage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'model/db_utils.dart';
import 'sharedpreferences.dart';
import 'userSettings.dart';

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Form key and database model
  final _formKey = GlobalKey<FormState>();
  var theSettings = SettingsModel();

  //Username and password for form fields
  String _username = '';
  String _password = '';

  double lat, long = 0.0;

  //Firestore cloud model
  UserModel _model = UserModel();

  @override
  Widget build(BuildContext context) {
    //Bloc for current user
    final CurrentUser currentUserBloC = Provider.of<CurrentUser>(context);

    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest)
        .then((userLocation) {
      if (this.mounted) {
        setState(() {
          lat = userLocation.latitude;
          long = userLocation.longitude;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  //Create login text
                  Text(
                    'Login',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //Sized box to create padding between the login title and the username entry field
            SizedBox(
              height: 30.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  //Form for name
                  TextFormField(
                    //Double check that the username is not empty
                    validator: (value) {
                      return value.isEmpty ? 'Please a valid username' : null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Username',
                      suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onChanged: (String value) {
                      _username = value;
                    },
                  ),
                  //Add gap between username and password field
                  SizedBox(
                    height: 20.0,
                  ),
                  // Form for password
                  TextFormField(
                    validator: (value) {
                      return value.isEmpty
                          ? 'Please enter a valid password'
                          : null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onChanged: (String value) {
                      _password = value;
                    },
                  ),
                ],
              ),
            ),
            //More padding
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forget password?',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  RaisedButton(
                    child: Text('Login'),
                    color: Color(0xffEE7B23),
                    onPressed: () {
                      // _validateInputs();
                      //Validate the inputs of the form
                      _model.getUser(_username).then((value) {
                        //Check to see if the username exists
                        if (value == null) {
                          //Clear for to fail validation
                          _formKey.currentState.reset();
                          //Show dialog for failed login
                          _showMyDialog(
                              "Invalid account", "That account does not exist");
                          //Check to see if the password matches the database password
                        } else if (value.password != _password) {
                          //Clear for to fail validation
                          _formKey.currentState.reset();

                          //Show dialog for failed login
                          _showMyDialog("Wrong password!",
                              "You have entered an incorrect password!");
                        }

                        //Validate form because if failed form will be empty
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          //CHANGE LOGINDATE

                          //Tries to add user to local db (if they don't exist)
                          potentialAddUser(value).then((value) {
                            Utils.saveUserLoggedInSharedPreference(true);
                            Utils.saveUserNameSharedPreference(value.username);

                            value.lat = this.lat;
                            value.long = this.long;

                            currentUserBloC.setUser(value);

                            //Set user location on login
                            currentUserBloC.currentUser.reference
                                .update({
                                  'lat': value.lat,
                                  'long': value.long,
                                })
                                .then((value) => print("User Updated"))
                                .catchError((error) =>
                                    print("Failed to update user: $error"));

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TabPage(
                                          title: "Final Project",
                                        )));
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            //Signup page if user clicks on signup button
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Signup(title: "Final Project")));
              },
              child: Text.rich(
                TextSpan(text: 'Don\'t have an account', children: [
                  TextSpan(
                    text: 'Signup',
                    style: TextStyle(color: Color(0xffEE7B23)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Searches database to check if the logged in user exists in the local DB
  //If they do, don't do anything
  //If they don't add them to the database.
  Future<User> potentialAddUser(value) async {
    var myBool = await theSettings.getSettingById(value.username);
    if (myBool == null) {
      // if user is NOT in database
      theSettings
          .insertSetting(userSettings(
              account: value.username, theme: 0, loginDate: 00000000))
          .then((value) {
        print("User added for the first time.");
      });
    } else {
      print("User already exists.");
    }
    return value;
  }

  // void _validateInputs() {
  //   _model.getUser(_username).then((value) {
  //     if (value == null) {
  //       _formKey.currentState.reset();
  //       _showMyDialog("Invalid account", "That account does not exist");
  //     } else if (value.password != _password) {
  //       _formKey.currentState.reset();
  //       _showMyDialog(
  //           "Wrong password!", "You have entered an incorrect password!");
  //     }
  //     if (_formKey.currentState.validate()) {
  //       _formKey.currentState.save();
  //       currentUserBloC.setUser(value);
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => TabPage(
  //                     title: "Final Project",
  //                   )));
  //     }
  //   });
  // }

  //Create dialog popup function for failed logins with different reasons
  Future<void> _showMyDialog(header, message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
