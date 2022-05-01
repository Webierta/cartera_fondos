import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';

class SqliteService {
  static const _databaseName = 'database.db';
  static const _databaseVersion = 1;
  static const table = 'Carteras';
  static const columnName = 'name';
  static const columnIsin = 'isin';
  static const columnDate = 'date';
  static const columnVL = 'vl';

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE $table ($columnName TEXT NOT NULL)',
        );
      },
      version: _databaseVersion,
    );
  }

  Future<void> createTableCartera(Cartera cartera) async {
    final Database db = await initDB();
    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS ${cartera.name} ($columnIsin TEXT PRIMARY KEY, $columnName TEXT NOT NULL)');
    } on DatabaseException catch (e) {
      print('ERROR: $e');
    }
  }

  // TODO: cambiar nombre table a fondo.name + cartera.name
  Future<void> createTableFondo(Fondo fondo) async {
    final Database db = await initDB();
    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS ${fondo.isin} ($columnDate INTEGER PRIMARY KEY, $columnVL REAL NOT NULL)');
    } on DatabaseException catch (e) {
      print('ERROR: $e');
    }
  }

  Future<void> insertCartera(Cartera cartera) async {
    final Database db = await initDB();
    await db.insert(table, cartera.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFondo(Cartera cartera, Fondo fondo) async {
    final Database db = await initDB();
    await db.insert(cartera.name, fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertVL(Fondo fondo) async {
    final Database db = await initDB();
    await db.insert(fondo.isin, fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Cartera>> getCarteras() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Cartera(name: maps[i][columnName]);
    });
  }

  Future<List<Fondo>> getFondos(Cartera cartera) async {
    final db = await initDB();
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
    final db = await initDB();
    // TODO: delete all fondos (otra funcion deletaAll)
    await db.delete(table, where: '$columnName = ?', whereArgs: [cartera.name]);
  }

  Future<void> deleteFondo(Cartera cartera, Fondo fondo) async {
    final db = await initDB();
    await db.delete(cartera.name, where: '$columnIsin = ?', whereArgs: [fondo.isin]);
  }

  Future<void> orderByName(List<Cartera> carteras) async {
    for (var cartera in carteras) {
      deleteCartera(cartera);
    }
    carteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in carteras) {
      insertCartera(cartera);
    }
  }

  Future<void> clearCartera() async {
    final db = await initDB();
    await db.rawQuery("DELETE FROM $table");
  }

  Future<void> clearFondo(Fondo fondo) async {
    final db = await initDB();
    await db.rawQuery("DELETE FROM ${fondo.isin}");
  }
}
