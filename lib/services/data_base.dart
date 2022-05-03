/*
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';

class DatabaseManager {
  static const _databaseName = 'database.db';
  static const _databaseVersion = 1;
  static const table = 'Carteras';
  static const columnName = 'name';
  static const columnIsin = 'isin';

  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    return _database ?? await _initDatabase();
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $table ($columnName TEXT NOT NULL)',
    );
  }

  Future<void> createTableCartera(Cartera cartera) async {
    Database db = await instance.database;
    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS ${cartera.name} ($columnIsin TEXT PRIMARY KEY, $columnName TEXT NOT NULL)');
    } on DatabaseException catch (e) {
      print('ERROR: $e');
    }
  }

  Future<void> insertCartera(Cartera cartera) async {
    Database db = await instance.database;
    await db.insert(table, cartera.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFondo(Cartera cartera, Fondo fondo) async {
    Database db = await instance.database;
    await db.insert(cartera.name, fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cartera>> getCarteras() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Cartera(name: maps[i][columnName]);
    });
  }

  Future<List<Fondo>> getFondos(Cartera cartera) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(cartera.name);
    return List.generate(maps.length, (i) {
      return Fondo(isin: maps[i][columnIsin], name: maps[i][columnName]);
    });
  }

  Future<int> getNumberFondos(Cartera cartera) async {
    var fondos = <Fondo>[];
    final data = await getFondos(cartera);
    fondos = data;
    return fondos.length;
  }

  Future<void> deleteCartera(Cartera cartera) async {
    Database db = await instance.database;
    // TODO: delete all fondos (otra funcion deletaAll)
    await db.delete(table, where: '$columnName = ?', whereArgs: [cartera.name]);
  }

  Future<void> deleteFondo(Cartera cartera, Fondo fondo) async {
    Database db = await instance.database;
    await db.delete(cartera.name, where: '$columnIsin = ?', whereArgs: [fondo.isin]);
  }

  Future<void> clearCartera() async {
    Database db = await instance.database;
    await db.rawQuery("DELETE FROM $table");
  }

  Future<void> clearFondo(Fondo fondo) async {
    Database db = await instance.database;
    await db.rawQuery("DELETE FROM ${fondo.isin}");
  }

  Future<void> orderCarteras(List<Cartera> carteras) async {
    for (var cartera in carteras) {
      deleteCartera(cartera);
    }
    carteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in carteras) {
      insertCartera(cartera);
    }
  }
}
*/
