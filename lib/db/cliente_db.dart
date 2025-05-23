import 'dart:io';

import 'package:clinik/model/cliente.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ClientesDB {
  Future<Database> _getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "clientes.db");
    String sql = """
    CREATE TABLE IF NOT EXISTS clientes (
        id INTEGER PRIMARY KEY,
        nome STRING,
        responsavel STRING,
        telefone STRING,
        cpf STRING,
        dataNasc INTEGER
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

  Future<void> insertCliente(Map<String, Object> cliente) async {
    // Get a reference to the database.
    final db = await _getDatabase();

    // print(agend.toMap());
    // carro.toMap().forEach((key, value) { print(value.runtimeType);});

    await db.insert(
      'clientes',
      cliente,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cliente>> getAll() async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('clientes');

    return List.generate(
      maps.length,
      (i) {
        return Cliente.fromMap(maps[i]);
      },
    );
  }

  Future<Cliente?> getByName(String nome) async {
    final db = await _getDatabase();

    final List<Map<String, dynamic>> clientsMap = await db.query("clientes");

    final Map<String, dynamic>? clientMap =
        (clientsMap.where((element) => element["nome"] == nome).toList().firstOrNull);

    if (clientMap != null) {
      return Cliente.fromMap(clientMap);
    } else {
      return null;
    }
  }

  Future<void> deletarCliente(int id) async {
    final db = await _getDatabase();
    await db.delete("clientes", where: "id = $id");
  }

  Future<void> update(int id, Map<String, dynamic> newCliente) async {
    final db = await _getDatabase();

    await db.update('clientes', newCliente, where: "id = $id");
  }
}
