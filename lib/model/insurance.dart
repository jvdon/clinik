import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Insurance {
  int id;
  String nome;

  Insurance({
    required this.id,
    required this.nome,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
    };
  }

  factory Insurance.fromMap(Map<String, dynamic> map) {
    return Insurance(
      id: map['id'] as int,
      nome: map['nome'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Insurance.fromJson(String source) => Insurance.fromMap(json.decode(source) as Map<String, dynamic>);
}
