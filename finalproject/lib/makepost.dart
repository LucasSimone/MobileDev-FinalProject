import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'animation/animationimage.dart';
import 'dart:io';
import 'model/user.dart';
import 'tabpage.dart';
import 'model/post.dart';
import 'notifications/notifications.dart';
import 'camera_page.dart';

class MakePost extends StatefulWidget {
  MakePost({Key key, this.title, this.user}) : super(key: key);
  final User user;
  final String title;

  @override
  _MakePostState createState() => _MakePostState();
}

enum Operation { resize, move }
enum Timeline { start, end }

class _MakePostState extends State<MakePost> {
  //notification setup
  final _notifications = Notifications();
  CollectionReference userposts;
  //current moveing operation
  Operation curOp = Operation.move;
  //animation timeline selection
  Timeline curFrame = Timeline.start;
  //bool for if there is a sub image in the post
  bool subImage = false;
  final inputtext = TextEditingController();

  //curve type for x direction, y direction and size change
  int curveTypeX = 0;
  int curveTypeY = 0;
  int curveTypeS = 0;

  //animation details
  //ratios, and positions
  var wx = 1.0;
  var wy = 1.0;
  var rwx = 0.2;
  var rwy = 0.2;
  var x1 = 1.0;
  var y1 = 1.0;
  var rx1 = 0.2;
  var ry1 = 0.2;
  var x2 = 1.0;
  var y2 = 1.0;
  var rx2 = 0.2;
  var ry2 = 0.2;

  var iw = 50.0;
  var ih = 50.0;
  var riw = 0.2;
  var rih = 0.2;
  var w1 = 50.0;
  var h1 = 50.0;
  var rw1 = 0.2;
  var rh1 = 0.2;
  var w2 = 50.0;
  var h2 = 50.0;
  var rw2 = 0.2;
  var rh2 = 0.2;

  //drop down option list for animation curves
  List<DropdownMenuItem<int>> dropDownOptions = [
    DropdownMenuItem<int>(
      value: 0,
      child: Text("Linear"),
    ),
    DropdownMenuItem<int>(
      value: 1,
      child: Text("Ease In-Out"),
    ),
    DropdownMenuItem<int>(
      value: 2,
      child: Text("Bounce Out"),
    ),
    DropdownMenuItem<int>(
      value: 3,
      child: Text("Elastic In-Out"),
    )
  ];
  //image file and sub image file
  var _image;
  var _subimage;
  //key for form
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _notifications.init();
    //userposts collection for posting to
    userposts = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('userposts');

    return Scaffold(
      backgroundColor: myInt == 0 ? Colors.white : Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      //post making form
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: myInt == 0 ? Colors.white : Colors.black,
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.all(5),
                        //if image selected, show image
                        child: _image == null
                            ? Text(
                                'No image selected.',
                                style: TextStyle(
                                  color:
                                      myInt == 0 ? Colors.black : Colors.white,
                                ),
                              )
                            : new LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                                return Stack(
                                  children: [
                                    //main image shown
                                    Image.file(
                                      _image,
                                    ),
                                    _subimage == null
                                        ? Container()
                                        //transformable sub image
                                        : Transform.translate(
                                            offset: Offset(wx, wy),
                                            child: Image.file(
                                              _subimage,
                                              height: ih,
                                              width: iw,
                                            ),
                                          ),
                                    _subimage == null
                                        ? Container()
                                        :
                                        //moveable sub image
                                        GestureDetector(
                                            onPanUpdate: (details) {
                                              setState(() {
                                                //move or resizing operations
                                                if (curOp == Operation.move) {
                                                  wx = details.localPosition.dx;
                                                  wy = details.localPosition.dy;
                                                  //restrictions so sub image doesnt move outside of main image
                                                  if (wx < 0) {
                                                    wx = 0;
                                                  } else if (wx + iw >
                                                      constraints.maxWidth) {
                                                    wx = constraints.maxWidth -
                                                        iw;
                                                  }
                                                  if (wy < 0) {
                                                    wy = 0;
                                                  } else if (wy + ih >
                                                      constraints.maxHeight) {
                                                    wy = constraints.maxHeight -
                                                        ih;
                                                  }
                                                  //position ratios
                                                  rwx =
                                                      wx / constraints.maxWidth;
                                                  rwy = wy /
                                                      constraints.maxHeight;
                                                  if (curFrame ==
                                                      Timeline.start) {
                                                    x1 = wx;
                                                    y1 = wy;
                                                    rx1 = rwx;
                                                    ry1 = rwy;
                                                  } else {
                                                    x2 = wx;
                                                    y2 = wy;
                                                    rx2 = rwx;
                                                    ry2 = rwy;
                                                  }
                                                } else {
                                                  iw =
                                                      details.localPosition.dx -
                                                          wx;
                                                  ih =
                                                      details.localPosition.dy -
                                                          wy;
                                                  if (iw < 0) {
                                                    iw = 0;
                                                  } else if (wx + iw >
                                                      constraints.maxWidth) {
                                                    iw = constraints.maxWidth -
                                                        wx;
                                                  }
                                                  if (ih < 0) {
                                                    ih = 0;
                                                  } else if (wy + ih >
                                                      constraints.maxHeight) {
                                                    ih = constraints.maxHeight -
                                                        wy;
                                                  }
                                                  //size ratios
                                                  riw =
                                                      iw / constraints.maxWidth;
                                                  rih = ih /
                                                      constraints.maxHeight;
                                                  if (curFrame ==
                                                      Timeline.start) {
                                                    w1 = iw;
                                                    h1 = ih;
                                                    rw1 = riw;
                                                    rh1 = rih;
                                                  } else {
                                                    w2 = iw;
                                                    h2 = ih;
                                                    rw2 = riw;
                                                    rh2 = rih;
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                  ],
                                );
                              })),
                    //text box for text input
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter text";
                          }
                          if (value.length > 300) {
                            return "Message must be under 300 characters";
                          }
                          return null;
                        },
                        controller: inputtext,
                        style: TextStyle(
                          color: myInt == 0 ? Colors.black : Colors.white,
                        ),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: myInt == 0 ? Colors.black : Colors.white,
                              ),
                            ),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: myInt == 0 ? Colors.black : Colors.white,
                            ))),
                      ),
                    ),
                    //upload main image and sub image buttons
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                getImage(0);
                              },
                              child: Text("Upload Image")),
                          _image == null
                              ? Container()
                              : ElevatedButton(
                                  onPressed: () {
                                    getImage(1);
                                  },
                                  child: Text("Upload SubImage")),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CameraPage(retImage: true),
                                  ),
                                ).then((var takenPhoto) {
                                  if (takenPhoto != null) {
                                    setState(() {
                                      _image = File(takenPhoto);
                                    });
                                  }
                                });
                              },
                              child: Text("Take Photo")),
                          _image == null
                              ? Container()
                              : ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CameraPage(retImage: true),
                                      ),
                                    ).then((var takenPhoto) {
                                      if (takenPhoto != null) {
                                        setState(() {
                                          _subimage = File(takenPhoto);
                                          subImage = true;
                                        });
                                      }
                                    });
                                  },
                                  child: Text("Take SubPhoto")),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: _subimage == null
                          ? Container()
                          :
                          //animation options
                          SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                      child: Theme(
                                          data: myInt == 0
                                              ? ThemeData.light()
                                              : ThemeData.dark(),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              //sub image transforming options
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Column(children: [
                                                    RadioListTile(
                                                        title: Text(
                                                          "Move",
                                                          style: TextStyle(
                                                            color: myInt == 0
                                                                ? Colors.black
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                        value: Operation.move,
                                                        groupValue: curOp,
                                                        onChanged:
                                                            (Operation op) {
                                                          setState(() {
                                                            curOp = op;
                                                          });
                                                        }),
                                                    RadioListTile(
                                                        title: Text(
                                                          "Resize",
                                                          style: TextStyle(
                                                            color: myInt == 0
                                                                ? Colors.black
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                        value: Operation.resize,
                                                        groupValue: curOp,
                                                        onChanged:
                                                            (Operation op) {
                                                          setState(() {
                                                            curOp = op;
                                                          });
                                                        }),
                                                  ])),
                                              //frame selection options
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Column(children: [
                                                    RadioListTile(
                                                        title: Text(
                                                          "Start",
                                                          style: TextStyle(
                                                            color: myInt == 0
                                                                ? Colors.black
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                        value: Timeline.start,
                                                        groupValue: curFrame,
                                                        onChanged:
                                                            (Timeline f) {
                                                          setState(() {
                                                            curFrame = f;
                                                            //update frame subimage
                                                            wx = x1;
                                                            wy = y1;
                                                            iw = w1;
                                                            ih = h1;
                                                          });
                                                        }),
                                                    RadioListTile(
                                                        title: Text(
                                                          "End",
                                                          style: TextStyle(
                                                            color: myInt == 0
                                                                ? Colors.black
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                        value: Timeline.end,
                                                        groupValue: curFrame,
                                                        onChanged:
                                                            (Timeline f) {
                                                          setState(() {
                                                            curFrame = f;
                                                            //update frame subimage
                                                            wx = x2;
                                                            wy = y2;
                                                            iw = w2;
                                                            ih = h2;
                                                          });
                                                        })
                                                  ]))
                                            ],
                                          ))),
                                  //preview animation button
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                      backgroundColor:
                                                          myInt == 0
                                                              ? Colors.white
                                                              : Colors.black,
                                                      appBar: AppBar(
                                                        title: Text("Preview"),
                                                      ),
                                                      body: Animated(
                                                        ispreview: true,
                                                        subfile: _subimage,
                                                        mainfile: _image,
                                                        ratioxfinal: rx2,
                                                        ratioyfinal: ry2,
                                                        ratioxinitial: rx1,
                                                        ratioyinitial: ry1,
                                                        ratiohfinal: rh2,
                                                        ratiohinitial: rh1,
                                                        ratiowfinal: rw2,
                                                        ratiowinitial: rw1,
                                                        curvesize: curveTypeS,
                                                        curvex: curveTypeX,
                                                        curvey: curveTypeY,
                                                        height: 200,
                                                        width: 200,
                                                      ),
                                                    )));
                                      },
                                      child: Text("Preview")),
                                  //animation curve selections
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Animation Curve in X Direction",
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      )),
                                      DropdownButton<int>(
                                        value: curveTypeX,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        onChanged: (int newValue) {
                                          setState(() {
                                            curveTypeX = newValue;
                                          });
                                        },
                                        items: dropDownOptions,
                                        dropdownColor: myInt == 0
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Animation Curve in Y Direction",
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      )),
                                      DropdownButton<int>(
                                        value: curveTypeY,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        onChanged: (int newValue) {
                                          setState(() {
                                            curveTypeY = newValue;
                                          });
                                        },
                                        items: dropDownOptions,
                                        dropdownColor: myInt == 0
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Animation Curve For Size",
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      )),
                                      DropdownButton<int>(
                                        value: curveTypeS,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: myInt == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        onChanged: (int newValue) {
                                          setState(() {
                                            curveTypeS = newValue;
                                          });
                                        },
                                        items: dropDownOptions,
                                        dropdownColor: myInt == 0
                                            ? Colors.white
                                            : Colors.black,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    )
                  ])),
            ),
          ),
        ),
      ),
      //upload button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (_image != null) {
              var now = new DateTime.now();
              print("Validated");
              if (_subimage != null) {
                //post animation
                uploadFile(_image).then((imagelink) {
                  uploadFile(_subimage).then((subimagelink) {
                    userposts.add({
                      'likers': [],
                      'userid': widget.user.id,
                      'text': inputtext.text,
                      'subimage': subimagelink,
                      'mainimage': imagelink,
                      'ratios': [rx1, ry1, rx2, ry2, rw1, rh1, rw2, rh2],
                      'curvex': curveTypeX,
                      'curvey': curveTypeY,
                      'curvesize': curveTypeS,
                      'isanimated': subImage,
                      'dateposted': now,
                    });
                    _notifications.sendNotificationNow(
                        "Posted", "Succesfully posted to your profile", "h");
                    Navigator.pop(context);
                  });
                }).catchError((error) {
                  _notifications.sendNotificationNow(
                      "Post Failed", "Failed to post to your profile", "h");
                });
              } else {
                //if no subimage just post regular image
                uploadFile(_image).then((imagelink) {
                  userposts.add({
                    'likers': [],
                    'userid': widget.user.id,
                    'text': inputtext.text,
                    'subimage': null,
                    'mainimage': imagelink,
                    'ratios': [rx1, ry1, rx2, ry2, rw1, rh1, rw2, rh2],
                    'curvex': curveTypeX,
                    'curvey': curveTypeY,
                    'curvesize': curveTypeS,
                    'isanimated': subImage,
                    'dateposted': now,
                  });
                  _notifications.sendNotificationNow(
                      "Posted", "Succesfully posted to your profile", "h");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TabPage(
                                title: "Final Project",
                              )));
                }).catchError((error) {
                  _notifications.sendNotificationNow(
                      "Post Failed", "Failed to post to your profile", "h");
                });
              }
            }
          }
        },
        tooltip: 'Post',
        child: Icon(Icons.file_upload),
      ),
    );
  }

  //upload image file to firestore, taken from signup.dart
  Future<String> uploadFile(File _image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${p.basename(_image.path)}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() {
      print('File Uploaded');
    });

    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  //get image file, taken from signup.dart
  Future<void> getImage(int ind) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        if (ind == 0) {
          _image = File(image.path);
        } else if (ind == 1) {
          _subimage = File(image.path);
          subImage = true;
        }
      } else {
        print('No image selected.');
      }
    });
  }
}
