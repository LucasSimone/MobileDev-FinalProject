import 'dart:io';

import 'package:finalproject/camera_page.dart';
import 'package:finalproject/login.dart';
import 'package:finalproject/model/user.dart';
import 'package:finalproject/model/user_model.dart';
import 'package:finalproject/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'notifications/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as p;

import 'app_localizations.dart';

class Signup extends StatefulWidget {
  Signup({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //Form key
  final _formKey = GlobalKey<FormState>();

  final _notifications = Notifications();

  //Signup information required for a new user
  String _username = '';
  String _password = '';
  DateTime _dob = DateTime.now();
  String _avatar = '';
  UserModel _model = UserModel();
  var _image;

  //Text controller for date picker
  var txt = TextEditingController();

  //Lanugae option
  bool isEnglish = false;

  @override
  Widget build(BuildContext context) {
    _notifications.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          width: 300,
                          child: Text(
                            AppLocalizations.of(context).translate('signup'),
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                        )),
                  ],
                ),
              ),
              //Padding between signup label and the form
              SizedBox(
                height: 30.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Form for name
                    TextFormField(
                      //Checks that field is not empty
                      validator: (value) {
                        return value.isEmpty
                            ? AppLocalizations.of(context)
                                .translate('pleaseEVU')
                            : null;
                      },
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context).translate('username'),
                        suffixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      //Set username value
                      onChanged: (String value) {
                        _username = value;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    // Form for model
                    TextFormField(
                      //Checks that field is not empty
                      validator: (value) {
                        return value.isEmpty
                            ? AppLocalizations.of(context)
                                .translate('pleaseEVP')
                            : null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context).translate('password'),
                        suffixIcon: Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      //Set password value
                      onChanged: (String value) {
                        _password = value;
                      },
                    ),
                    //Padding
                    SizedBox(
                      height: 20.0,
                    ),
                    // Form for date
                    TextFormField(
                      readOnly: true,
                      controller: txt,
                      validator: (value) {
                        return value.isEmpty
                            ? AppLocalizations.of(context)
                                .translate('pleaseEVD')
                            : null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)
                            .translate('dateOfBirth'),
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      //Create a date picker when the form is tapped
                      onTap: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        ).then((value) {
                          //Set date variable value and text form value
                          setState(() {
                            _dob = value;
                            txt.text = toDateString(_dob);
                          });
                        });
                      },
                    ),
                    SizedBox(
                      height: 48,
                    ),
                    Text(
                        AppLocalizations.of(context)
                            .translate('profilePicture'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, //Center Row contents horizontally,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(18.0),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.33,
                            height: MediaQuery.of(context).size.width * 0.1,
                            child: RaisedButton(
                              child: Text(AppLocalizations.of(context)
                                  .translate('selectPhoto')),
                              color: Color(0xffEE7B23),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(18.0),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.33,
                            height: MediaQuery.of(context).size.width * 0.1,
                            child: RaisedButton(
                              child: Text(AppLocalizations.of(context)
                                  .translate('takePhoto')),
                              color: Color(0xffEE7B23),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CameraPage(retImage: true),
                                  ),
                                ).then((var takenPhoto) {
                                  setState(() {
                                    _image = File(takenPhoto);
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(),
                          border: Border.all(),
                          color: Colors.white),
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: _image == null
                            ? Text(AppLocalizations.of(context)
                                .translate('pleaseSetPP'))
                            : Image.file(_image),
                      ),
                    ),
                  ],
                ),
              ),

              //padding
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('forgotPass'),
                      style: TextStyle(fontSize: 12.0),
                    ),
                    RaisedButton(
                      child: Text(
                          AppLocalizations.of(context).translate('signUp')),
                      color: Color(0xffEE7B23),
                      onPressed: () {
                        //Validate inputs on submit
                        _validateInputs();
                      },
                    ),
                  ],
                ),
              ),
              //Padding
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  //Redirect to login on button click
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login(
                                title: "Final Project",
                              )));
                },
                child: Text.rich(
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('alreadyHaveAccount'),
                      children: [
                        TextSpan(
                          text:
                              AppLocalizations.of(context).translate('signIn'),
                          style: TextStyle(color: Color(0xffEE7B23)),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Validate form inputs by checking database to see if account exists
  //Followed by adding user to the cloud
  void _validateInputs() {
    //Grab username from firestore
    _model.getUser(_username).then((value) {
      //If the account already exists exit
      if (value != null) {
        _formKey.currentState.reset();
        _showMyDialog("Invalid account", "That account already exists");
      }
      //Validate that all the entries are avalid
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        //Send notification that sign up happened
        _notifications.sendNotificationNow(
            "Signed up", "Succesfully signed up", "h");

        //String imageURL = await uploadFile(_image);
        // "avatar":
        //Create new user objecta and add it to the database

        uploadFile(_image).then((imageURL) {
          User u = User(
              username: _username,
              password: _password,
              avatar: FieldValue.arrayUnion([imageURL]),
              dob: _dob,
              friends: [],
              friendRequests: [],
              lat: 0.0,
              long: 0.0);
          _model.insertUser(u);

          //Pop back to login
          Navigator.of(context).pop();
        });
      }
    });
  }

  //Create dialog popup function for failed signups with different reasons
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

  //Upload file to firestore
  Future<String> uploadFile(File _image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${p.basename(_image.path)}');
    UploadTask uploadTask = storageReference.putFile(_image);
    // uploadTask.whenComplete(() => null);
    await uploadTask.whenComplete(() {
      print('File Uploaded');
    });

    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  //Grab an image from the image picker
  Future<void> getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }
}
