import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'model/user.dart';
import 'themes/colour.dart';
import 'package:finalproject/camera_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:finalproject/model/user_model.dart';
import 'package:path/path.dart' as p;

import 'package:provider/provider.dart';



class ChangeProfilePic extends StatefulWidget {
  ChangeProfilePic({Key key, this.title}) : super(key: key);
  final String title;


  @override
  _ChangeProfilePic createState() => _ChangeProfilePic();

}


class _ChangeProfilePic extends State<ChangeProfilePic> {

  UserModel _model = UserModel();
  var _image;

  @override
  Widget build(BuildContext context) {

    final CurrentUser bloC = context.watch<CurrentUser>();

    return Scaffold(
      appBar: AppBar(backgroundColor: redcol, title: Text(widget.title)),
      body: ListView(children: <Widget>[

        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(),
              border: Border.all(),
              color: Colors.white),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: _image == null
                ? Text('Please set a profile picture')
                : Image.file(_image),
          ),
        ),


        Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          children: [

          Padding(
            padding:EdgeInsets.all(18.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width * 0.33,
              height: MediaQuery.of(context).size.width * 0.1,

              child: RaisedButton(
                child: Text('Select Photo'),
                color: Color(0xffEE7B23),
                onPressed: () {
                  getImage();
                },
              ),
            ),
          ),

          Padding(
            padding:EdgeInsets.all(18.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width * 0.33,
              height: MediaQuery.of(context).size.width * 0.1,

              child: RaisedButton(
                child: Text('Take Photo'),
                color: Color(0xffEE7B23),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(retImage: true),
                    ),
                  ).then((var takenPhoto)
                    {
                      setState(() {
                        _image = File(takenPhoto);
                      });
                    }
                  );
                },
              ),
            ),
          ),
        ],),

        Center(
        child: Padding(
            padding:EdgeInsets.all(18.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width * 0.33,
              height: MediaQuery.of(context).size.width * 0.1,

              child: RaisedButton(
                child: Text('Save Profile Picture'),
                color: Color(0xffEE7B23),
                onPressed: () {
                  uploadFile(_image).then((imageURL){
                    
                    _model.updateAvatar(bloC.currentUser.reference,bloC.currentUser , FieldValue.arrayUnion([imageURL]));
                    bloC.currentUser.avatar = imageURL;
                    setState(() {});
                    Navigator.pop(context);
                  }
                  );
                  
                },
              ),
            ),
          ),
        )


      ],),


    );

  }

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

}