import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//class for a user's post
class Post {
  Post(
      {this.text,
      this.mainimage,
      this.subimage,
      this.likers,
      this.dateposted,
      this.ratios,
      this.curvesize,
      this.curvex,
      this.curvey,
      this.userid,
      isanimated});
  String id;
  //String user;
  String mainimage;
  String subimage;
  String text;
  //list of user ids who have liked post
  List likers;
  bool isanimated;
  DateTime dateposted;

  DocumentReference reference;

  //Animation variables
  //in order {ratioxinitial, ratioyinitial, ratioxfinal,ratioyfinal,ratiowinitial,ratiohinitial,ratiowfinal,ratiohfinal}
  List ratios;
  // double ratioxinitial;
  // double ratioyinitial;
  // double ratioxfinal;
  // double ratioyfinal;
  // double ratiowinitial;
  // double ratiohinitial;
  // double ratiowfinal;
  // double ratiohfinal;
  String userid;
  int curvex;
  int curvey;
  int curvesize;

  Post.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.id = this.reference.id;
    this.likers = map['likers'];
    this.userid = map['userid'];
    this.text = map['text'];
    this.mainimage = map['mainimage'];
    this.subimage = map['subimage'];
    this.ratios = map['ratios'];
    this.curvex = map['curvex'];
    this.curvey = map['curvey'];
    this.curvesize = map['curvesize'];
    this.isanimated = map['isanimated'];
    this.dateposted = DateTime.parse(map['dateposted'].toDate().toString());
  }

  Map<String, dynamic> toMap() {
    return {
      'likers': this.likers,
      'userid': this.userid,
      'text': this.text,
      'subimage': this.subimage,
      'id': this.id,
      'mainimage': this.mainimage,
      'ratios': this.ratios,
      'curvex': this.curvex,
      'curvey': this.curvey,
      'curvesize': this.curvesize,
      'isanimated': this.isanimated,
      'dateposted': this.dateposted,
    };
  }
}
