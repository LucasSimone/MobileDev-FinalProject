import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../userSettings.dart';

//This function creates a database called settings_manager if there already
//isn't one.
//Settings_manager has the following attributes:
//id - int [Primary key]
//account - string 
//theme - integer (used to represent boolean)
//loginDate - integer
class DBUtils {
  static Future<Database> init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'settings_manager.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE settings(id INTEGER PRIMARY KEY, account TEXT, theme INTEGER, loginDate INTEGER)");
      },
      version: 1,
    );
    return database;
  }
}

class SettingsModel {
  //Gets all the settings from the database
  Future<List<userSettings>> getAllSettings() async {
    final db = await DBUtils.init();
    List<Map<String, dynamic>> maps = await db.query('settings');
    List<userSettings> result = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        result.add(userSettings.fromMap(maps[i]));
      }
    }
    return result;
  }

  //Searches through the database to find a specific account name
  //Returns that account names userSettings
  Future<userSettings> getSettingById(String accName) async{
    final db = await DBUtils.init();
    List<Map<String, dynamic>> maps = await db.query('settings');
    List<userSettings> result = [];
    if(maps.length > 0){
      for (int i =0; i<maps.length; i++){
        if(userSettings.fromMap(maps[i]).account == accName){
          //If the account name was found in the database
          return userSettings.fromMap(maps[i]);
        }
      }
    }
    //If unable to find account settings, return null to notify that the user
    //doesn't exist
    return null;
  }

  //Adds a userSetting to the database
  Future<int> insertSetting(userSettings mySetting) async {
    final db = await DBUtils.init();
    return db.insert(
      'settings', //db name
      mySetting.toMap(), //map function
      conflictAlgorithm: ConflictAlgorithm.replace, //If conflict, replace
    );
  }

  //Updates a specific user's userSettings
  Future<int> updateSetting(userSettings mySetting) async {
    final db = await DBUtils.init();
    await db.update(
      'settings', //db name
      mySetting.toMap(), //Map function
      where: "id = ?", //Where the id is the determining factor
      whereArgs: [mySetting.id], //Update mySetting.id's settings.
    );
  }

  //Deletes a specific users userSettings
  Future<int> deleteSettingById(int id) async {
    final db = await DBUtils.init();
    await db.delete(
      'settings', //db name
      where: "id = ?", //Where the id is the determining factor
      whereArgs: [id], //Delete mySetting.id's settings.
    );
  }

  //Deletes all entries of userSettings from the database
  Future<void> deleteAllSettings() async {
    final db = await DBUtils.init();
    await db.delete(
      'settings', //db name                               
    );
  }
}
