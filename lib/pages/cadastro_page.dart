import 'package:clinik/db/agendamentos_db.dart';
import 'package:clinik/db/cliente_db.dart';
import 'package:clinik/db/insurance_db.dart';
import 'package:clinik/model/cliente.dart';
import 'package:clinik/model/insurance.dart';
import 'package:clinik/partials/customButton.dart';
import 'package:clinik/partials/customInput.dart';
import 'package:clinik/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'clientes_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  // Cliente
  TextEditingController cliente = TextEditingController();

  // Agendamento
  DateTime dataAgendamento = DateTime.now();
  MoneyMaskedTextController valor =
      MoneyMaskedTextController(decimalSeparator: ",", thousandSeparator: ".", leftSymbol: "R\$ ");
  TextEditingController plano = TextEditingController();
  TextEditingController status = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Paciente
            InputDecorator(
              decoration: const InputDecoration(
                  label: Text(
                    "Paciente",
                    style: TextStyle(fontSize: 24),
                  ),
                  border: OutlineInputBorder()),
              child: Column(
                children: [
                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      // showSelectedItems: true,
                      showSearchBox: true,
                      searchDelay: Duration.zero,
                      itemBuilder: (context, item, isSelected) {
                        return ListTile(
                          title: Text(item),
                          // subtitle: Text(item.cpf),
                        );
                      },
                    ),
                    asyncItems: (text) async {
                      List<Cliente> clientes = await ClientesDB().getAll();

                      return clientes
                          .map(
                            (e) => e.nome,
                          )
                          .toList();
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Paciente",
                        hintText: "Selecione o paciente",
                      ),
                    ),
                    itemAsString: (item) => item,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          cliente.text = value;
                        });
                      }
                    },
                  ),
                  CustomButton(
                    height: 50,
                    child: Text("Cadastrar novo paciente"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => buildAddCliente(context),
                      ).then(
                        (value) {
                          setState(() {});
                        },
                      );
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            // Agendamento
            InputDecorator(
              decoration: const InputDecoration(
                  label: Text(
                    "Agendamento",
                    style: TextStyle(fontSize: 24),
                  ),
                  border: OutlineInputBorder()),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomInput(
                        label: "valor",
                        icon: CupertinoIcons.money_dollar,
                        controller: valor,
                        width: 150,
                        type: TextInputType.number,
                        fontSize: 14,
                      ),
                      const SizedBox(width: 15),
                      selectorPlano()
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 100,
                        child: IconButton(
                          onPressed: () async {
                            DateTime? data = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 150)),
                              lastDate: DateTime.now().add(
                                const Duration(days: 150),
                              ),
                            );
                            if (data != null) {
                              setState(() {
                                dataAgendamento = dataAgendamento.copyWith(
                                  day: data.day,
                                  month: data.month,
                                  year: data.year,
                                );
                              });
                            }
                          },
                          icon: buildDisplay(
                              "Data", DateFormat("dd/MM/yyyy").format(dataAgendamento), Icons.calendar_month,
                              fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 150,
                        height: 100,
                        child: IconButton(
                          onPressed: () async {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 12, minute: 00),
                            );
                            if (time != null) {
                              setState(() {
                                dataAgendamento = dataAgendamento.copyWith(hour: time.hour, minute: time.minute);
                              });
                            }
                          },
                          icon: buildDisplay(
                              "Horário", DateFormat("HH:mm").format(dataAgendamento), Icons.hourglass_bottom,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  buildTipoSelector(status),
                  // SizedBox(height: 10),
                ],
              ),
            ),
            CustomButton(
              child: const Text("Adicionar"),
              onTap: () async {
                if (_key.currentState!.validate()) {
                  Cliente? client = await ClientesDB().getByName(cliente.text);

                  if (client != null) {
                    Map<String, Object> agendamento = {
                      "cliente": client.toJson(),
                      "data": dataAgendamento.millisecondsSinceEpoch,
                      "valor": valor.numberValue,
                      "status": status.text,
                      "plano": plano.text
                    };

                    AgendamentosDB().insertAgendamento(agendamento);

                    Navigator.of(context).pop();
                  } else {}
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget selectorPlano() {
    return FutureBuilder(
      future: InsuranceDB().getAll(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(
                child: Column(
                  children: [
                    Icon(Icons.error),
                    Text("Unable to load data"),
                  ],
                ),
              );
            } else {
              List<Insurance> planos = snapshot.requireData;
              return DropdownMenu(
                width: 160,
                controller: plano,
                hintText: "Plano de Saude",
                dropdownMenuEntries: planos.map((e) {
                  return DropdownMenuEntry(value: e.nome, label: e.nome);
                }).toList(),
              );
            }
          default:
            return const Center(
              child: Column(
                children: [
                  Icon(Icons.question_mark),
                  Text("Unknown state"),
                ],
              ),
            );
        }
      },
    );
  }
}
