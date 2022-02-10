import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'utils.dart';

import 'model/user.dart';

class FriendMap extends StatefulWidget {
  FriendMap({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FriendMapState createState() => _FriendMapState();
}

class _FriendMapState extends State<FriendMap> {
  var _geolocator = Geolocator();

  //Default centre location
  var centre = LatLng(43.9457842, -78.895896);
  List<Marker> markers = [];

  // Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  @override
  initState() {
    super.initState();
    //Set the centre of the map to the current location
    _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((result) {
      if (this.mounted) {
        setState(() {
          centre = LatLng(result.latitude, result.longitude);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final CurrentUser bloC = context.watch<CurrentUser>();

    _geolocator.checkGeolocationPermissionStatus().then((status) {
      // print('Geolocation status: $status');
    });

    //Async function to place all of the friend marker
    placeFriendMarkers(bloC.currentUser);

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          //Small zoom number to show large map
          zoom: 2.5,
          plugins: [PopupMarkerPlugin()],
          onTap: (_) => _popupLayerController.hidePopup(),
          center: centre,
        ),
        layers: [
          // for OpenStreetMaps
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PopupMarkerLayerOptions(
            markers: markers,
            popupSnap: PopupSnap.top,
            popupController: _popupLayerController,
            popupBuilder: (_, Marker marker) {
              //Check that the marker is our custom marker type
              if (marker is FriendMarker) {
                return FriendMarkerPopup(friend: marker.friend);
              }
              return Card(child: const Text('Not a friend marker'));
            },
          ),
        ],
      ),
    );
  }

  //Function to get all current users in the firestore
  Future<List<User>> getUsers() async {
    var users = await FirebaseFirestore.instance.collection('users').get();
    return users.docs
        .map(
          (docSnap) =>
              User.fromMap(docSnap.data(), reference: docSnap.reference),
        )
        .toList();
  }

  //Place all markers for friends
  placeFriendMarkers(User currentUser) async {
    //Loop through all users
    for (User user in await getUsers()) {
      //If they have the default location of 0,0 skip them
      if (user.lat == 0.0 && user.long == 0.0) continue;

      //If they are not a friend skip them
      if (!currentUser.friends.contains(user.username)) continue;

      if (this.mounted) {
        setState(() {
          markers.add(
            //Add a custom friend marker
            FriendMarker(
              friend: Friend(
                user: user,
              ),
            ),
          );
        });
      }
    }
  }
}

class Friend {
  static const double size = 45;

  Friend({this.user});

  final User user;
}

//Wrap marker as FriendMarker to pass custom data
class FriendMarker extends Marker {
  FriendMarker({@required this.friend})
      : super(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          height: Friend.size,
          width: Friend.size,
          point: LatLng(friend.user.lat, friend.user.long),
          builder: (BuildContext ctx) => Container(
              child: CircleAvatar(
                  backgroundImage: NetworkImage(friend.user.avatar))),
        );

  final Friend friend;
}

class FriendMarkerPopup extends StatelessWidget {
  const FriendMarkerPopup({Key key, this.friend}) : super(key: key);
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(friend.user.avatar, width: 200),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(friend.user.username),
            Text("${toDateString(friend.user.dob)}"),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text('${friend.user.lat}-${friend.user.long}'),
          ],
        ),
      ),
    );
  }
}
