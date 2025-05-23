// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Cliente {
  int id;
  String nome;
  String telefone;
  String cpf;
  String responsavel;
  DateTime dataNasc;

  Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.cpf,
    required this.responsavel,
    required this.dataNasc,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'cpf': cpf,
      'responsavel': responsavel,
      'dataNasc': dataNasc.millisecondsSinceEpoch,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      cpf: map['cpf'] as String,
      responsavel: map['responsavel'] as String,
      dataNasc: DateTime.fromMillisecondsSinceEpoch(map['dataNasc'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cliente.fromJson(String source) => Cliente.fromMap(json.decode(source) as Map<String, dynamic>);
}
