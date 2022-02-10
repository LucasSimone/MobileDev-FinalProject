import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/user.dart';
import 'model/post.dart';
import 'utils.dart';
import 'tabpage.dart';

class StatsTable extends StatefulWidget {
  StatsTable({Key key, this.user}) : super(key: key);
  final User user;
  @override
  _StatsTableState createState() => _StatsTableState();
}

class _StatsTableState extends State<StatsTable> {
  List<Post> _posts;
  int _sortColumnIndex;
  bool _sortAscending;
  void initState() {
    _sortColumnIndex = 0;
    _sortAscending = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myInt == 0 ? Colors.white : Colors.blueGrey,
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: getPosts(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //loading bar while loading users
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              //fill posts list with post classes if posts list is empty
              if (_posts == null) {
                _posts = snapshot.data.docs
                    .map((DocumentSnapshot document) => Post.fromMap(
                        document.data(),
                        reference: document.reference))
                    .toList();
              }
              return DataTable(
                  //data table filled with post texts, post dates and number of likes
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: <DataColumn>[
                    //text sorter
                    DataColumn(
                      numeric: false,
                      label: Text('Text',
                          style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white,
                          )),
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                          _posts.sort((a, b) {
                            if (ascending) {
                              return a.text.compareTo(b.text);
                            } else {
                              return b.text.compareTo(a.text);
                            }
                          });
                        });
                      },
                    ),
                    DataColumn(
                      //date sorter
                      numeric: false,
                      label: Text("Date",
                          style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white,
                          )),
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                          _posts.sort((a, b) {
                            if (ascending) {
                              return a.dateposted.compareTo(b.dateposted);
                            } else {
                              return b.dateposted.compareTo(a.dateposted);
                            }
                          });
                        });
                      },
                    ),
                    DataColumn(
                      //number of likes sorter
                      numeric: true,
                      label: Text("Likes",
                          style: TextStyle(
                            color: myInt == 0 ? Colors.black : Colors.white,
                          )),
                      onSort: (index, ascending) {
                        setState(() {
                          _sortColumnIndex = index;
                          _sortAscending = ascending;
                          _posts.sort((a, b) {
                            if (ascending) {
                              return a.likers.length.compareTo(b.likers.length);
                            } else {
                              return b.likers.length.compareTo(a.likers.length);
                            }
                          });
                        });
                      },
                    )
                  ],
                  //data table rows
                  rows: _posts
                      .map((post) => DataRow(cells: <DataCell>[
                            DataCell(Text(post.text,
                                style: TextStyle(
                                  color:
                                      myInt == 0 ? Colors.black : Colors.white,
                                ))),
                            DataCell(
                              Text(toDateString(post.dateposted),
                                  style: TextStyle(
                                    color: myInt == 0
                                        ? Colors.black
                                        : Colors.white,
                                  )),
                            ),
                            DataCell(Text(post.likers.length.toString(),
                                style: TextStyle(
                                  color:
                                      myInt == 0 ? Colors.black : Colors.white,
                                )))
                          ]))
                      .toList());
            }
          }),
    );
  }

  Future<QuerySnapshot> getPosts() async {
    //get all posts for a user
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('userposts')
        .orderBy("dateposted", descending: true)
        .get();
  }
}
