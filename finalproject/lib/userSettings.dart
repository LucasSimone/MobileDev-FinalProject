import 'package:flutter/material.dart';

class userSettings{
  int id;
  String account;
  int theme;
  int loginDate; 
  userSettings({this.id, this.account, this.theme, this.loginDate});

  userSettings.fromMap(Map<String,dynamic> map){
    this.id = map['id'];
    this.account = map['account'];
    this.theme = map['theme'];
    this.loginDate = map['loginDate'];
  }

  Map<String, dynamic> toMap(){
    return{
      'id': this.id,
      'account': this.account,
      'theme': this.theme,
      'loginDate': this.loginDate,
    };
  }

  String toString(){
    return 'userSettings(id: $id, account: $account, theme: $theme, loginDate: $loginDate)';
  }
}