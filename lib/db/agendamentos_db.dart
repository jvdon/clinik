import 'dart:io';

import 'package:clinik/model/agendamento.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AgendamentosDB {
  Future<Database> _getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "agendamentos.db");
    String sql = """
    CREATE TABLE IF NOT EXISTS agendamentos (
        id INTEGER PRIMARY KEY,
        cliente STRING,
        data INTEGER,
        status TEXT DEFAULT 'AGENDADO',
        valor DOUBLE,
        plano TEXT
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

  Future<void> insertAgendamento(Map<String, Object> agend) async {
    // Get a reference to the database.
    final db = await _getDatabase();

    // print(agend.toMap());
    // carro.toMap().forEach((key, value) { print(value.runtimeType);});

    await db.insert(
      'agendamentos',
      agend,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Agendamento>> getAll() async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('agendamentos');

    // final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM agendamentos INNER JOIN clientes ON nome == agendamentos.cliente == clientes.nome");

    return List.generate(
      maps.length,
      (i) {
        return Agendamento.fromMap(maps[i]);
      },
    );
  }

  Future<void> deletarAgendamento(int id) async {
    final db = await _getDatabase();
    await db.delete("agendamentos", where: "id = $id");
  }

  Future<void> mudarStatus(int id, STATUS_AGENDAMENTO status) async {
    final db = await _getDatabase();

    await db.update('agendamentos', {"status": status.name}, where: "id = $id");
  }

  Future<void> update(int id, Map<String, Object> newAgendamento) async {
    final db = await _getDatabase();

    await db.update('agendamentos', newAgendamento, where: "id = $id");
  }

  Future<void> reagendar(int id, DateTime novaData) async {
    final db = await _getDatabase();

    await db.update('agendamentos', {"data": novaData.millisecondsSinceEpoch}, where: "id = $id");
  }
}
