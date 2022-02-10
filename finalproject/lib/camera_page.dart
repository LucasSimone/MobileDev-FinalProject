import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CameraPage extends StatefulWidget {
  CameraPage({Key key, this.title, this.retImage}) : super(key: key);
  final String title;
  bool retImage;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  //List<CameraDescription> cameras;
  // Add two variables to the state class to store the CameraController and
  // the Future.
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.

    availableCameras().then((cameraList) {
      print(cameraList);

      _controller = CameraController(cameraList.first, ResolutionPreset.medium);

      _initializeControllerFuture = _controller.initialize();
      if (this.mounted) {
        setState(() {});
      }
    });

    // Next, initialize the controller. This returns a Future.
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  bool currentPic = false;
  var imgPath;

  var _geolocator = Geolocator();
  Position _currentPosition;
  String currentCity;

  var filters = ["", "", "", "", "Loving Life", "What a Nice Day!"];
  var filterFonts = [
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.pink,
    Colors.green
  ];
  var filterFontSize = [40.0, 48.0, 15.0, 17.0, 45.0, 50.0];
  var filterColours = [
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.pink,
    Colors.green
  ];
  var filterAlignments = [
    Alignment.bottomCenter,
    Alignment.bottomCenter,
    Alignment.topRight,
    Alignment.bottomCenter,
    Alignment.bottomCenter,
    Alignment.bottomCenter
  ];
  var filterRotations = [0, 0, 0, 1, 3, 0];
  var currFilter = 0;

  @override
  Widget build(BuildContext context) {
    _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position userLocation) {
      _currentPosition = userLocation;
      _geolocator
          .placemarkFromCoordinates(
              _currentPosition.latitude, _currentPosition.longitude)
          .then((List<Placemark> places) {
        for (Placemark place in places) {
          if (this.mounted) {
            setState(() {
              currentCity = '${place.locality}';
              filters[1] = currentCity;
              filters[2] = currentCity;
              filters[3] = currentCity;
            });
          }
        }
      });
    });

    if (currentPic == false) {
      return Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Construct the path where the image should be saved using the
              // pattern package.
              final path = join(
                // Store the picture in the temp directory.
                // Find the temp directory using the `path_provider` plugin.
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );

              // Attempt to take a picture and log where it's been saved.
              await _controller.takePicture(path);

              imgPath = path;

              //Get user Position
              _geolocator
                  .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
                  .then((Position userLocation) {
                _currentPosition = userLocation;
              });

              if (_currentPosition != null) {
                _geolocator
                    .placemarkFromCoordinates(
                        _currentPosition.latitude, _currentPosition.longitude)
                    .then((List<Placemark> places) {
                  for (Placemark place in places) {
                    setState(() {
                      currentCity = '${place.locality}';
                      print(currentCity);
                    });
                  }
                });
              } else {
                setState(() {
                  currentCity = 'Unknown';
                  print(currentCity);
                });
              }

              // If the picture was taken, display it on a new screen.
              //Check if image has to be returned
              if (widget.retImage == true) {
                Navigator.pop(context, path);
              } else {
                setState(() {
                  currentPic = true;
                });
              }
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
        ),
      );
    } else {
      return Scaffold(
          body: SwipeDetector(
            onSwipeUp: () {
              print("up");
              setState(() {
                if (currFilter == 5) {
                  currFilter = 0;
                } else {
                  currFilter++;
                }
                print(currFilter);
              });
            },
            onSwipeDown: () {
              print("Down");
              setState(() {
                if (currFilter == 0) {
                  currFilter = 5;
                } else {
                  currFilter--;
                }
                print(currFilter);
              });
            },
            swipeConfiguration: SwipeConfiguration(
              verticalSwipeMinVelocity: 30.0,
              verticalSwipeMinDisplacement: 30.0,
              verticalSwipeMaxWidthThreshold: 200.0,
            ),
            child: Center(
              child: Screenshot(
                controller: screenshotController,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FittedBox(
                        child: Image.file(File(imgPath)),
                        fit: BoxFit.fill,
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: filterRotations[currFilter],
                      child: Container(
                          padding: EdgeInsets.all(10),
                          alignment: filterAlignments[currFilter],
                          child: Text(
                            filters[currFilter],
                            style: TextStyle(
                                color: filterColours[currFilter],
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: filterFontSize[currFilter]),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Stack(children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: FloatingActionButton(
                  heroTag: "btn1",
                  child: Icon(Icons.clear_rounded),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  elevation: 0.0,
                  onPressed: () {
                    setState(() {
                      currentPic = false;
                    });
                  },
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: FloatingActionButton(
                  heroTag: "btn2",
                  child: Icon(Icons.save),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.grey,
                  elevation: 1.0,
                  onPressed: () {
                    screenshotController.capture().then((File image) async {
                      // GallerySaver.saveImage(image.path)
                      //     .then((value) => print("Saved"));
                    }).catchError((onError) {
                      print(onError);
                    });
                    setState(() {
                      currentPic = false;
                      final snackBar =
                          SnackBar(content: Text("Picture Saved!"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    });
                  },
                ),
              ),
            )
          ]));
    }
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FittedBox(
          child: Image.file(File(imagePath)),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
