import 'package:finalproject/login.dart';
import 'package:finalproject/model/user.dart';
import 'package:finalproject/model/user_model.dart';
import 'package:finalproject/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sharedpreferences.dart';
import "tabpage.dart";
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrentUser(),
      child: MyApp(),
    ),
  );
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  AnimationController _controller;

  //User login status
  bool userIsLoggedIn;

  @override
  void initState() {
    //Add an animation controller to spin the logo instead of the default
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    //Repeat the spinning
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.repeat();
      }
    });

    super.initState();
  }

  @override
  dispose() {
    //Dispose of the animation
    _controller.dispose();
    super.dispose();
  }

  //Get login state
  getLoggedInState() async {
    //Check if there is a logged in user
    bool login = await Utils.getUserLoggedInSharedPreference();
    await Firebase.initializeApp();
    //get logged in users name
    String u = await Utils.getUserNameSharedPreference();
    //Grab user from firestore
    User user = await UserModel().getUser(u);

    //Provide logged in user to CurrentUser provider
    Provider.of<CurrentUser>(context, listen: false).setUser(user);

    return login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //Wait for firestore and user to load before going to main app page
        future: getLoggedInState(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error initializing firebase');
            return Text('Error initializing firebase');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            userIsLoggedIn = snapshot.data;

            return MaterialApp(
              supportedLocales: [
                Locale('en', 'US'),
                Locale('pt', 'PT'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],

              localeResolutionCallback: (locale, supportedLocales) {
                // Check if the current device locale is supported
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }
                // If the locale of the device is not supported, use the first one
                // from the list (English, in this case).
                return supportedLocales.first;
              },

              title: 'Final Project',
              theme: ThemeData(
                primarySwatch: Colors.red,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              //If the user is logged in take them to the homepage, otherwise
              //take them to the login page
              home: (userIsLoggedIn == null || !userIsLoggedIn)
                  ? Login(
                      title: "Final Project",
                    )
                  : TabPage(
                      title: "Final Project",
                    ),
              routes: <String, WidgetBuilder>{
                '/login': (BuildContext context) =>
                    Login(title: 'Final Project'),
                '/signup': (BuildContext context) =>
                    Signup(title: 'Final Project'),
              },
              //debugShowCheckedModeBanner: false,
            );
          } else {
            _controller.forward();
            return MaterialApp(
                title: 'Final Project',
                theme: ThemeData(
                  primarySwatch: Colors.red,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                home: Scaffold(
                    appBar: AppBar(
                      title: Text("Final Project"),
                      backgroundColor: Colors.red,
                    ),
                    body: Center(
                      //Call rotation animation
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                        child: Image.asset(
                          "assets/logo_stacked.png",
                        ),
                      ),
                    )));
          }
        });
  }
}
