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
  static const table = 'carfoin';
  static const columnId = 'id';
  static const columnInput = 'input';
  // TABLE CARTERA
  static const columnName = 'name';
  static const columnIsin = 'isin';
  //static const columnMoneda = 'moneda';
  static const columnDivisa = 'divisa';
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
        await db.execute('''
        CREATE TABLE $table (
          $columnId INTEGER PRIMARY KEY NOT NULL,
          $columnInput TEXT NOT NULL)
        ''');
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

  //Future<void> createTableCartera(Cartera cartera) async {
  Future<void> createTableCartera(String tableCartera) async {
    await openDb();
    //var nameTable = '_$id';
    await _db.execute('''
    CREATE TABLE IF NOT EXISTS $tableCartera (
      $columnIsin TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnDivisa TEXT)
    ''');
  }

  Future<void> createTableFondo(String tableFondo) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFondo (
        $columnDate INTEGER PRIMARY KEY,
        $columnPrecio REAL NOT NULL)
      ''');
  }

  Future<void> createTableMercado(String tableMercado) async {
    await openDb();
    //var nameTable = 'mk_' + fondo.isin + '_' + '$cartera.id';
    await _db.execute('''
      CREATE TABLE IF NO EXISTS $tableMercado (
        id INTEGER PRIMARY KEY,
        $columnTipo INTEGER,
        $columnDateMercado INTEGER,
        $columnParticipaciones REAL,
        $columnPrecioMercado REAL)
      ''');
  }

  /*Future<void> insertCartera(Cartera cartera) async {
    await openDb();
    await _db.insert(table, cartera.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }*/

  /*Future<void> insertCartera(String input) async {
    await openDb();
    //await _db.insert(table, input, conflictAlgorithm: ConflictAlgorithm.replace);
    await _db.rawInsert('INSERT INTO $table ($columnName) VALUES($input)');
  }*/

  Future<int> insertCartera(Map<String, dynamic> row) async {
    await openDb();
    return await _db.insert(table, row);
  }

  Future<void> insertFondo(String tableCartera, Map<String, dynamic> row) async {
    await openDb();
    //await _db.insert('$cartera.id', fondo.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    await _db.insert(tableCartera, row, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /*Future<void> insertDataApi(Cartera cartera, Fondo fondo,
      {String? moneda, double? lastPrecio, int? lastDate}) async {
    await openDb();
    await _db.insert(cartera.name, fondo.toMapDataApi(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    //TODO: ConflictAlgorithm.replace reordena los fondos y lo pone al final ??
  }*/

  Future<void> insertVL(String tableFondo, Map<String, dynamic> row) async {
    await openDb();
    // var nameTable = fondo.isin + '_' + '$cartera.id';
    //await _db.insert(nameTable, valor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await _db.insert(tableFondo, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /*Future<void> insertListVL(String tableFondo, List<Map<String, dynamic>> rows) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    for (var row in rows) {
      await _db.insert(tableFondo, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }*/

  /*Future<void> getCarteras() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(table);
    */ /*_dbCarteras = List.generate(maps.length,
      (i) => Cartera(name: maps[i][columnName]),
    );*/ /*
    _dbCarteras = List.generate(maps.length, (i) {
      return Cartera(id: maps[i][columnId], name: maps[i][columnName]);
    });
  } */

  Future<void> getCarteras() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(table);
    _dbCarteras = List.generate(maps.length, (i) {
      return Cartera(id: maps[i][columnId], name: maps[i][columnInput]);
    });
  }

  Future<void> vaciarTabla() async {
    //DELETE FROM tab;
    await openDb();
    //await _db.execute("DELETE FROM $table");
    await _db.rawUpdate("DELETE FROM $table");
  }

  Future<void> resetId() async {
    await openDb();
    //DELETE FROM `sqlite_sequence` WHERE `name` = 'table_name';
    // delete from sqlite_sequence where name='your_table';
    //await _db.execute("DELETE FROM sqlite_sequence WHERE name=$table");
    await _db.rawUpdate("DELETE FROM sqlite_sequence WHERE name=$table");
  }

  Future<void> renameTable(String oldName, String newName) async {
    await openDb();
    await _db.execute("ALTER TABLE $oldName RENAME TO $newName");
  }

  /*Future<List> getTables() async {
    await openDb();
    var resultado = [];
    (await _db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      resultado.add(row.values);
    });
    return resultado;
  }*/

  Future<List<String>> getNameTables() async {
    var tableNames = (await _db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: false);
    return tableNames;
  }

  Future<void> orderCarteras() async {
    /*await openDb();
    final List<Map<String, dynamic>> maps = await _db.query(table);
    List<Cartera> dbCarteras = List.generate(
      maps.length,
      (i) => Cartera(id: maps[i][columnId], name: maps[i][columnInput]),
    );
    dbCarteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in dbCarteras) {
      deleteCartera(cartera);
    }
    dbCarteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in dbCarteras) {
      //insertCartera(cartera);
      Map<String, dynamic> row = {'input': cartera.name};
      insertCartera(row);
    }*/
    await openDb();
    // SELECT * FROM tasks_table ORDER BY list_index ASC
    List<Map<String, dynamic>> maps = await _db.query(table, orderBy: '$columnInput ASC');
    List<Cartera> dbCarteras = List.generate(
      maps.length,
      (i) => Cartera(id: maps[i][columnId], name: maps[i][columnInput]),
    );
    //await deleteAllCarteras();
    /*for (var cartera in dbCarteras) {
      await _db.delete(table, where: '$columnId = ?', whereArgs: [cartera.id]);
    }*/
    //await vaciarTabla();
    //await resetId();
    /*for (var cartera in dbCarteras) {
      Map<String, dynamic> row = {'input': cartera.name};
      await updateCartera(cartera.id, row);
      //await insertCartera(row);
    }*/

    Map<String, dynamic> row2 = {'input': dbCarteras[0].name};
    await updateCartera(1, row2);
    Map<String, dynamic> row1 = {'input': dbCarteras[1].name};
    await updateCartera(2, row1);
  }

  Future<void> updateCartera(int id, Map<String, dynamic> row) async {
    await openDb();
    await _db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> getFondos(String tableCartera) async {
    await openDb();
    //var nameTable = '_$id';
    final List<Map<String, dynamic>> maps = await _db.query(tableCartera);
    List<Fondo> fondos = List.generate(
      maps.length,
      (i) => Fondo(
        isin: maps[i][columnIsin],
        name: maps[i][columnName],
        divisa: maps[i][columnDivisa],
      ),
    );
    /*for (var i = 0; i < fondos.length; i++) {
      fondos[i].divisa = maps[i][columnDivisa];
      //fondos[i].lastPrecio = maps[i][columnLastPrecio];
      //fondos[i].lastDate = maps[i][columnLastDate];
    }*/
    _dbFondos = fondos;
  }

  Future<void> getNumberFondos(String tableCartera) async {
    /*var fondos = <Fondo>[];
    final data = await getFondos(cartera);
    fondos = data;
    return fondos.length;*/
    await openDb();
    final result = await _db.rawQuery('SELECT COUNT(*) FROM $tableCartera');
    _dbNumFondos = Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> getValores(String tableFondo) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    final List<Map<String, dynamic>> maps = await _db.query(tableFondo);
    _dbValores = List.generate(
      maps.length,
      (i) => Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]),
    );
  }

  Future<void> getValoresByOrder(String tableFondo) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    List<Map<String, dynamic>> maps = await _db.query(tableFondo, orderBy: '$columnDate DESC');
    _dbValoresByOrder = List.generate(
      maps.length,
      (i) => Valor(date: maps[i][columnDate], precio: maps[i][columnPrecio]),
    );
  }

  Future<void> clearCarfoin() async {
    await openDb();
    // await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    await _db.delete(table);
  }

  Future<void> deleteCartera(Cartera cartera) async {
    await openDb();
    //get all fondos de cartera y delete
    await _db.delete(table, where: '$columnId = ?', whereArgs: [cartera.id]);
    //await _db.execute("DROP TABLE IF EXISTS ${cartera.id}");
    //await _db.delete('${cartera.id}');
    //await _db.execute("DROP TABLE IF EXISTS ${cartera.id}");
  }

  Future<void> deleteFondo(String tableCartera, Fondo fondo) async {
    await openDb();
    await _db.delete(tableCartera, where: '$columnIsin = ?', whereArgs: [fondo.isin]);
    // await db.execute("DROP TABLE IF EXISTS $nameTable");
  }

  Future<void> deleteValor(String tableFondo, int date) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    await _db.delete(tableFondo, where: '$columnDate = ?', whereArgs: [date]);
  }

  /*Future<void> deleteAllFondos(String tableCartera) async {
    await openDb();
    //await _db.delete(tableCartera);
    await _db.execute("DROP TABLE IF EXISTS $tableCartera");
  }*/

  /*Future<void> deleteAllValores(String tableFondo) async {
    await openDb();
    //var nameTable = fondo.isin + '_' + '$cartera.id';
    await _db.execute("DROP TABLE IF EXISTS $tableFondo");
  }*/

  Future<void> eliminaTabla(String nameTable) async {
    await openDb();
    await _db.execute("DROP TABLE IF EXISTS $nameTable");
  }
}
