import 'dart:io';
import 'package:async/async.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/cartera.dart';
import '../models/fondo.dart';
import '../models/valor.dart';

class Sqlite {
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
  //TABLE MERCADO
  static const columnTipo = 'tipo';
  static const columnDateMercado = 'date';
  static const columnParticipaciones = 'participaciones';
  static const columnPrecioMercado = 'precio';

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  late Database _db;
  List<Cartera> _dbCarteras = [];
  List<Fondo> _dbFondos = [];
  int _dbNumFondos = 0;
  List<Valor> _dbValores = [];
  List<Valor> _dbValoresByOrder = [];

  List<Cartera> get dbCarteras => _dbCarteras;
  List<Fondo> get dbFondos => _dbFondos;
  int get dbNumFondos => _dbNumFondos;
  List<Valor> get dbValores => _dbValores;
  List<Valor> get dbValoresByOrder => _dbValoresByOrder;

  Future<void> _initDb() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, _databaseName);
    _db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE $table ($columnName TEXT NOT NULL)',
        );
      },
    );
  }

  Future<bool> openDb() async {
    await _memoizer.runOnce(() async {
      await _initDb();
    });
    return true;
  }

  // TODO: future específico para fondos
  Future<bool> openDbFondos() async {
    await _memoizer.runOnce(() async {
      await _initDb();
      // await getFondos(cartera); // TODO: posible con provider sin pasar argumento ??
    });
    return true;
  }

  /*existeTable(String name) async {
    await openDb();
    try {
      var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM $name'));
      return true;
    } catch (e) {
      return false;
    }
  }*/

  Future<void> createTableCartera(Cartera cartera) async {
    await openDb();
    await _db.execute('''
    CREATE TABLE IF NOT EXISTS ${cartera.name} (
      $columnIsin TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnMoneda TEXT,
      $columnLastPrecio REAL,
      $columnLastDate INTEGER)
    ''');
  }

  Future<void> createTableFondo(Cartera cartera, Fondo fondo) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $nameTable (
        $columnDate INTEGER PRIMARY KEY,
        $columnPrecio REAL NOT NULL)
      ''');
  }

  Future<void> createTableMercado(Cartera cartera, Fondo fondo) async {
    await openDb();
    var nameTable = 'mk_' + fondo.isin + '_' + cartera.name;
    await _db.execute('''
      CREATE TABLE IF NO EXISTS $nameTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTipo INTEGER,
        $columnDateMercado INTEGER,
        $columnParticipaciones REAL,
        $columnPrecioMercado REAL)
      ''');
  }

  Future<void> insertCartera(Cartera cartera) async {
    await openDb();
    await _db.insert(table, cartera.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFondo(Cartera cartera, Fondo fondo) async {
    await openDb();
    await _db.insert(cartera.name, fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertDataApi(Cartera cartera, Fondo fondo,
      {String? moneda, double? lastPrecio, int? lastDate}) async {
    await openDb();
    await _db.insert(cartera.name, fondo.toMapDataApi(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    //TODO: ConflictAlgorithm.replace reordena los fondos y lo pone al final ??
  }

  Future<void> insertVL(Cartera cartera, Fondo fondo, Valor valor) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    await _db.insert(nameTable, valor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertListVL(Cartera cartera, Fondo fondo, List<Valor> valores) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    for (var valor in valores) {
      await _db.insert(nameTable, valor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> getCarteras() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(table);
    _dbCarteras = List.generate(
      maps.length,
      (i) => Cartera(name: maps[i][columnName]),
    );
  }

  /*Future<void> orderCarteras() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(table);
    List<Cartera> dbCarteras = List.generate(
      maps.length,
      (i) => Cartera(name: maps[i][columnName]),
    );
    dbCarteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in dbCarteras) {
      deleteCarteraInCarteras(cartera);
    }
    dbCarteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in dbCarteras) {
      insertCartera(cartera);
    }
  }*/

  Future<void> getFondos(Cartera cartera) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(cartera.name);
    List<Fondo> fondos = List.generate(
      maps.length,
      (i) => Fondo(isin: maps[i][columnIsin], name: maps[i][columnName]),
    );
    for (var i = 0; i < fondos.length; i++) {
      fondos[i].moneda = maps[i][columnMoneda];
      fondos[i].lastPrecio = maps[i][columnLastPrecio];
      fondos[i].lastDate = maps[i][columnLastDate];
    }
    _dbFondos = fondos;
  }

  Future<void> getNumberFondos(Cartera cartera) async {
    /*var fondos = <Fondo>[];
    final data = await getFondos(cartera);
    fondos = data;
    return fondos.length;*/
    await openDb();
    final result = await _db.rawQuery('SELECT COUNT(*) FROM $cartera.name');
    _dbNumFondos = Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> getValores(Cartera cartera, Fondo fondo) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    final List<Map<String, dynamic>> maps = await _db.query(nameTable);
    _dbValores = List.generate(
      maps.length,
      (i) => Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]),
    );
  }

  Future<void> getValoresByOrder(Cartera cartera, Fondo fondo) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    List<Map<String, dynamic>> maps = await _db.query(nameTable, orderBy: '$columnDate DESC');
    _dbValoresByOrder = List.generate(
      maps.length,
      (i) => Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]),
    );
  }

  Future<void> deleteCarteraInCarteras(Cartera cartera) async {
    await openDb();
    //get all fondos de cartera y delete
    await _db.delete(table, where: '$columnName = ?', whereArgs: [cartera.name]);
  }

  Future<void> deleteAllCarteraInCarteras() async {
    await openDb();
    await _db.delete(table);
  }

  Future<void> deleteFondoInCartera(Cartera cartera, Fondo fondo) async {
    await openDb();
    await _db.delete(cartera.name, where: '$columnIsin = ?', whereArgs: [fondo.isin]);
    // await db.execute("DROP TABLE IF EXISTS $nameTable");
  }

  Future<void> deleteAllFondosInCartera(Cartera cartera) async {
    await openDb();
    await _db.delete(cartera.name);
  }

  Future<void> deleteValoresInFondo(Cartera cartera, Fondo fondo, int date) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    await _db.delete(nameTable, where: '$columnDate = ?', whereArgs: [date]);
  }

  Future<void> deleteAllValoresInFondo(Cartera cartera, Fondo fondo) async {
    await openDb();
    var nameTable = fondo.isin + '_' + cartera.name;
    await _db.execute("DROP TABLE IF EXISTS $nameTable");
  }
}
