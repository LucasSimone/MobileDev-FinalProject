import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

class UserModel {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<User> getUser(username) async {
    var foundUser = await users.where("username", isEqualTo: username).get();
    User u;
    if (foundUser.docs.isEmpty) {
      return null;
    } else {
      foundUser.docs.forEach((result) {
        u = User.fromMap(result.data(), reference: result.reference);
      });
    }

    return u;
  }

  Future<void> insertUser(User user) async {
    return users
        .add({
          'username': user.username,
          'avatar': user.avatar,
          'password': user.password,
          'dob': user.dob,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> deleteUserById(DocumentReference reference) async {
    reference
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  //takes reference to user and updates the user
  Future<void> updateAvatar(
      DocumentReference reference, User u, var avatar) async {
    reference
        .set({
          'username': u.username,
          'password': u.password,
          'dob': u.dob,
          'avatar': avatar,
          'friends': u.friends,
          'friendRequests': u.friendRequests,
          'lat': u.lat,
          'long': u.long,
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  //takes reference to user and updates the user
  Future<void> updateFriendRequests(
      DocumentReference reference, List friendRequests) async {
    reference
        .update({
          'friendRequests': friendRequests,
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  //takes reference to user and updates the user
  Future<void> updateFriends(DocumentReference reference, List friends) async {
    reference
        .update({
          'friends': friends,
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  //Add a chatroom to the firestore
  addChatRoom(chatRoom, chatRoomId) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  //Get the chat messages given an ID
  getChats(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  //Add a chat message
  addMessage(String chatRoomId, chatMessageData) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  //Get chats for a user
  getUserChats(String currentName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: currentName)
        .snapshots();
  }
}
