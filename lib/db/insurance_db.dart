import 'dart:io';

import 'package:clinik/model/insurance.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class InsuranceDB {
  Future<Database> _getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "insurances.db");
    String sql = """
    CREATE TABLE IF NOT EXISTS insurance (
        id INTEGER PRIMARY KEY,
        nome TEXT
    );
    """;

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          sql,
        );
      },
      onConfigure: (db) {
        return db.execute(
          sql,
        );
      },
      version: 1,
    );
  }

  Future<void> insertInsurance(Map<String, Object> insurance) async {
    // Get a reference to the database.
    final db = await _getDatabase();


    await db.insert(
      'insurance',
      insurance,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Insurance>> getAll() async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('insurance');

    return List.generate(
      maps.length,
      (i) {
        return Insurance.fromMap(maps[i]);
      },
    );
  }

  Future<void> deletarInsurance(int id) async {
    final db = await _getDatabase();
    await db.delete("insurance", where: "id = $id");
  }

  
}
