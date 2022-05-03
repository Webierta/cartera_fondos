import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';

class SqliteService {
  static const _databaseName = 'database.db';
  static const _databaseVersion = 1;
  static const table = 'Carteras';
  // TABLE CARTERA
  static const columnName = 'name';
  static const columnIsin = 'isin';
  static const columnMoneda = 'moneda';
  static const columnLastPrecio = 'lastPrecio';
  static const columnLastDate = 'lastDate';
  // TABLE FONDO
  static const columnDate = 'date';
  static const columnPrecio = 'precio';

  // BASE DE DATOS Y TABLAS

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
          'CREATE TABLE IF NOT EXISTS ${cartera.name} ($columnIsin TEXT PRIMARY KEY, $columnName TEXT NOT NULL, $columnMoneda TEXT, $columnLastPrecio REAL, $columnLastDate INTEGER)');
    } on DatabaseException catch (e) {
      print('ERROR: $e');
    }
  }

  Future<void> createTableFondo(Cartera cartera, Fondo fondo) async {
    final Database db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS $nameTable ($columnDate INTEGER PRIMARY KEY, $columnPrecio REAL NOT NULL)');
    } on DatabaseException catch (e) {
      print('ERROR: $e');
    }
  }

  // INSERTAR DATOS

  Future<void> insertCartera(Cartera cartera) async {
    final Database db = await initDB();
    await db.insert(table, cartera.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFondo(Cartera cartera, Fondo fondo) async {
    final Database db = await initDB();
    await db.insert(cartera.name, fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertDataApi(Cartera cartera, Fondo fondo,
      {String? moneda, double? lastPrecio, int? lastDate}) async {
    final Database db = await initDB();
    await db.insert(cartera.name, fondo.toMapDataApi(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertVL(Cartera cartera, Fondo fondo, Valor valor) async {
    final Database db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    await db.insert(nameTable, valor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertListVL(Cartera cartera, Fondo fondo, List<Valor> valores) async {
    final Database db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    for (var valor in valores) {
      await db.insert(nameTable, valor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // OBTENER DATOS

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
    List<Fondo> fondos = List.generate(maps.length, (i) {
      return Fondo(isin: maps[i][columnIsin], name: maps[i][columnName]);
    });
    for (var i = 0; i < fondos.length; i++) {
      fondos[i].moneda = maps[i][columnMoneda];
      fondos[i].lastPrecio = maps[i][columnLastPrecio];
      fondos[i].lastDate = maps[i][columnLastDate];
    }
    return fondos;
  }

  Future<int> getNumberFondos(Cartera cartera) async {
    var fondos = <Fondo>[];
    final data = await getFondos(cartera);
    fondos = data;
    return fondos.length;
  }

  Future<List<Valor>> getValores(Cartera cartera, Fondo fondo) async {
    final db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    final List<Map<String, dynamic>> maps = await db.query(nameTable);
    return List.generate(maps.length, (i) {
      return Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]);
    });
  }

  Future<List<Valor>> getValoresByOrder(Cartera cartera, Fondo fondo) async {
    final db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    List<Map<String, dynamic>> maps = await db.query(nameTable, orderBy: '$columnDate DESC');
    // await db.query('SELECT * FROM $nameTable ORDER BY $columnDate DESC');
    // await db.query('Notes', orderBy: NoteColumn.createdAt);
    return List.generate(maps.length, (i) {
      return Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]);
    });
  }

  Future<int> getNumberValores(Cartera cartera, Fondo fondo) async {
    var valores = <Valor>[];
    final data = await getValores(cartera, fondo);
    // await database.rawQuery('SELECT COUNT(*) FROM Test')
    valores = data;
    return valores.length;
  }

  // ELIMINAR DATOS

  Future<void> deleteCartera(Cartera cartera) async {
    final db = await initDB();
    // TODO: delete all fondos (otra funcion deletaAll)
    await db.delete(table, where: '$columnName = ?', whereArgs: [cartera.name]);
  }

  Future<void> deleteFondo(Cartera cartera, Fondo fondo) async {
    final db = await initDB();
    await db.delete(cartera.name, where: '$columnIsin = ?', whereArgs: [fondo.isin]);
  }

  Future<void> clearCartera() async {
    final db = await initDB();
    await db.rawQuery("DELETE FROM $table");
  }

  Future<void> clearFondo(Cartera cartera, Fondo fondo) async {
    final db = await initDB();
    var nameTable = fondo.isin + '_' + cartera.name;
    await db.rawQuery("DELETE FROM $nameTable");
  }

  // CONSULTAR Y REORDENAR DATOS

  Future<void> orderByName(List<Cartera> carteras) async {
    for (var cartera in carteras) {
      deleteCartera(cartera);
    }
    carteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in carteras) {
      insertCartera(cartera);
    }
  }
}
