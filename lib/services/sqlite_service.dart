import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cartera.dart';

class SqliteService {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE Carteras (name TEXT NOT NULL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertCartera(Cartera cartera) async {
    final Database db = await initDB();
    await db.insert(
      'Carteras', cartera.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // abort ?
    );
  }

  Future<List<Cartera>> getCarteras() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('Carteras');
    return List.generate(maps.length, (i) {
      return Cartera(name: maps[i]['name']);
    });
  }

  Future<void> deleteCartera(String name) async {
    final db = await initDB();
    // TODO: delete all fondos (otra funcion deletaAll)
    await db.delete(
      'Carteras',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> orderByName(List<Cartera> carteras) async {
    for (var cartera in carteras) {
      deleteCartera(cartera.name);
    }

    carteras.sort((a, b) => a.name.compareTo(b.name));
    for (var cartera in carteras) {
      insertCartera(cartera);
    }
  }
}
