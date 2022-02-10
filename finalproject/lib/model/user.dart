import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  User(
      {this.username,
      this.avatar,
      this.dob,
      this.password,
      this.friends,
      this.friendRequests,
      this.lat,
      this.long});
  String id;
  String username;
  var avatar;
  String password;
  DateTime dob;
  List friends;
  List friendRequests;
  double lat;
  double long;
  DocumentReference reference;

  User.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.id = this.reference.id;
    this.username = map['username'];
    this.avatar = map['avatar'][0];
    this.password = map['password'];
    this.dob = DateTime.parse(map['dob'].toDate().toString());
    this.friends = map['friends'] != null ? map['friends'] : [];
    this.friendRequests =
        map['friendRequests'] != null ? map['friendRequests'] : [];
    this.lat = map['lat'] != null ? map['lat'] : 0.0;
    this.long = map['long'] != null ? map['long'] : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'username': this.username,
      'avatar': this.avatar,
      'password': this.password,
      'dob': this.dob,
      'friends': this.friends,
      'friendRequests': this.friendRequests,
      'lat': this.lat,
      'long': this.long,
    };
  }

  bool attemptAddFriend(String friend) {
    if (this.friendRequests.contains(friend)) {
      this.friends.add(friend);
      this.friendRequests.remove(friend);
      return true;
    }

    return false;
  }

  String toString() {
    return 'Todo{id: $id, name: $username, avatar: $avatar}';
  }
}

class CurrentUser extends ChangeNotifier {
  /// Internal, private state of the cart.
  User _currentUser = null;

  User get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
