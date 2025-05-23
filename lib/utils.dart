import 'package:clinik/model/agendamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

Map<String, Color> palette = {
  "green1": fromHex("#219653"),
  "green2": fromHex("#27AE60"),
  "green3": fromHex("#6FCF97"),
  "white": fromHex("#F2F2F2"),
  "gray": fromHex("#333333"),
  "red": fromHex("#EB5757"),
  "blue": fromHex("#2F80ED"),
};

List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(DateTime(
        startDate.year,
        startDate.month,
        // In Dart you can set more than. 30 days, DateTime will do the trick
        startDate.day + i));
  }
  return days;
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

Widget buildDisplay(String label, String content, IconData icon, {double width = 150, double fontSize = 10}) {
  return Container(
    width: width,
    height: width * 0.35,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 24),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 5),
            Text(
              content,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 3,
                wordSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildTipoSelector(TextEditingController controller) {
  return Container(
    height: 40,
    child: DropdownMenu<STATUS_AGENDAMENTO>(
      width: 250,
      leadingIcon: const Icon(Icons.wysiwyg),
      label: const Text("STATUS"),
      controller: controller,
      enableSearch: true,
      dropdownMenuEntries: STATUS_AGENDAMENTO.values.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList(),
    ),
  );
}

Map<STATUS_AGENDAMENTO, Color> corAgenda = {
  STATUS_AGENDAMENTO.CONFIRMADO: Colors.blue,
  STATUS_AGENDAMENTO.FINALIZADO: Colors.green,
  STATUS_AGENDAMENTO.AGENDADO: Colors.green,
  STATUS_AGENDAMENTO.DEVOLUTIVA: Colors.green,
  STATUS_AGENDAMENTO.CANCELADO: Colors.red,
  STATUS_AGENDAMENTO.FERIADO: Colors.red,
  STATUS_AGENDAMENTO.F_TERAPEUTA: Colors.red,
  STATUS_AGENDAMENTO.F_PACIENTE: Colors.red,
  STATUS_AGENDAMENTO.JUSTIFICADO: Colors.red,
  STATUS_AGENDAMENTO.ANAMNESE: Colors.purple,
  STATUS_AGENDAMENTO.REAGENDAR: Colors.purple,
};
