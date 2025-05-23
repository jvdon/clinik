// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:clinik/model/cliente.dart';

class Agendamento {
  int id;
  Cliente cliente;
  DateTime data;
  STATUS_AGENDAMENTO status;
  double valor;
  String plano;

  Agendamento({
    required this.id,
    required this.cliente,
    required this.data,
    required this.status,
    required this.valor,
    required this.plano,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cliente': cliente.toMap(),
      'data': data.millisecondsSinceEpoch,
      'status': status.name,
      'valor': valor,
      'plano': plano,
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    try {
      return Agendamento(
        id: map['id'] as int,
        cliente: Cliente.fromJson(map['cliente'] as String),
        data: DateTime.fromMillisecondsSinceEpoch(map['data'] as int),
        status: STATUS_AGENDAMENTO.values.byName(map['status'] as String),
        valor: map['valor'] as double,
        plano: map['plano'] as String,
      );
    } catch (e) {
      return Agendamento(
        id: map['id'] as int,
        cliente: Cliente.fromJson(map['cliente'] as String),
        data: DateTime.fromMillisecondsSinceEpoch(map['data'] as int),
        status: STATUS_AGENDAMENTO.ANAMNESE,
        valor: map['valor'] as double,
        plano: map['plano'] as String,
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory Agendamento.fromJson(String source) => Agendamento.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum STATUS_AGENDAMENTO {
  AGENDADO,
  ANAMNESE,
  CANCELADO,
  CONFIRMADO,
  DEVOLUTIVA,
  EVOLUCAO_OK,
  F_TERAPEUTA,
  F_PACIENTE,
  FERIADO,
  FINALIZADO,
  JUSTIFICADO,
  REAGENDAR,
}
