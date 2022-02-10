import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";

  //Save if a user is logged in to shared preferences
  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  //Save the username the is logged on
  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }

  //Fetch is a user is currently logged in
  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey) ?? false;
  }

  //Grab the user that is currently logged in
  static Future<String> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserNameKey);
  }
}
