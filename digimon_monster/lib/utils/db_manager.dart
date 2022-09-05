import 'dart:convert';

import 'package:digimon_monster/Base/base_model.dart';
import 'package:digimon_monster/Game/card_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBManager {
  static final DBManager _manager = DBManager._();
  factory DBManager() {
    return _manager;
  }
  DBManager._();

  Future<void> initDB() async {
    await DBManager().openDB(CardModel("", ""));
  }

  String _path;
  Database _database;

  Future<String> _dbPath() async {
    if (_path == null) {
      String databasesPath = await getDatabasesPath();
      _path = join(databasesPath, 'dtcg.db');
    }
    return _path;
  }

  Future<void> openDB(BaseModel model) async {
    String path = await _dbPath();
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      Map<String, String> map = model.paramaDBMap();
      String sql =
          "CREATE TABLE ${model.tableName()} (pid INTEGER PRIMARY KEY, ";
      int index = 0;
      for (var key in map.keys) {
        if (index == 0) {
          sql = sql + "$key ${map[key]}";
        } else {
          sql = sql + ", $key ${map[key]}";
        }
        index += 1;
      }
      sql = sql + ")";
      await db.execute(sql);
    });
  }

  deleteDB() async {
    String path = await _dbPath();
    await deleteDatabase(path);
  }

  Future<void> insertDB(BaseModel model) async {
    Map<String, dynamic> map = model.toJsonMap();
    String paramaStr = "INSERT INTO ${model.tableName()} (";
    String valueStr = " VALUES(";
    int index = 0;
    for (var key in map.keys) {
      if (index == 0) {
        paramaStr = paramaStr + "$key";
        valueStr = valueStr + "${map[key]}";
      } else {
        paramaStr = paramaStr + ", $key";
        valueStr = valueStr + ", ${map[key]}";
      }
      index += 1;
    }
    paramaStr = paramaStr + ")";
    valueStr = valueStr + ")";
    String sql = paramaStr + valueStr;

    await _database.transaction((txn) async {
      int id1 = await txn.rawInsert(sql);
      print(id1);
    });
  }

  Future<void> insertBatchDB(BaseModel model) async {
    // await _database.transaction((txn) async {
    Batch batch = _database.batch();
    batch.insert(model.tableName(), model.toJsonMap());
    var result = await batch.commit();
    print(result);
    // });
  }

  Future<String> queryAll() async {
    List<Map> list = await _database.rawQuery('SELECT * FROM CARD_TABLE');
    String upgradeInfoStr = list[1]["upgradeInfo"];
    String jsonStr = json.encode(list);
    return jsonStr;
  }

  Future<Map> queryCardWithId(String cardId) async {
    Batch batch = _database.batch();
    batch.query("CARD_TABLE", where: "cardId = '$cardId'");

    List r = await batch.commit();
    List firstMap = r.first;
    if (firstMap.length > 0) {
      Map resultMap = firstMap.first;
      return resultMap;
    } else {
      return null;
    }
  }
}
