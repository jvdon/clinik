import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:clinik/db/cliente_db.dart';
import 'package:clinik/db/insurance_db.dart';
import 'package:clinik/model/insurance.dart';
import 'package:clinik/pages/clientes_page.dart';
import 'package:clinik/partials/customButton.dart';
import 'package:clinik/partials/customInput.dart';
import 'package:clinik/partials/textIcon.dart';
import 'package:clinik/utils.dart';
import 'package:clinik/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:clinik/db/agendamentos_db.dart';
import 'package:clinik/model/agendamento.dart';
import 'package:clinik/model/cliente.dart';
import 'package:clinik/pages/cadastro_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  List<DateTime> datas = [];
  DateTime selectedDate = DateTime.now();

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  Future<String?> createGoogleMeetEvent(Agendamento agendamento) async {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) return null; // user canceled sign in

    final GoogleSignInAuthentication auth = await account.authentication;
    final accessToken = auth.accessToken;

    final event = {
      "summary": "Consulta com ${agendamento.cliente.nome}",
      "description": "Data/Hora: ${format(agendamento.data)} ",
      "start": {"dateTime": agendamento.data.toIso8601String(), "timeZone": "America/Sao_Paulo"},
      "end": {
        "dateTime": agendamento.data.add(Duration(hours: 1)).toUtc().toIso8601String(),
        "timeZone": "America/Sao_Paulo"
      },
      "conferenceData": {
        "createRequest": {"requestId": "some-random-id-${DateTime.now().millisecondsSinceEpoch}"}
      }
    };

    final response = await http.post(
      Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events?conferenceDataVersion=1',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meetLink = data['conferenceData']?['entryPoints']?.firstWhere(
        (entry) => entry['entryPointType'] == 'video',
        orElse: () => null,
      )?['uri'];

      return meetLink; // This is your Google Meet link
    } else {
      print('Failed to create event: ${response.body}');
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    datas = getDaysInBeteween(
      selectedDate.subtract(const Duration(days: 1)),
      selectedDate.add(
        const Duration(days: 1),
      ),
    );
  }

  List<Agendamento> selected = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AgendamentosDB().getAll(),
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
              List<Agendamento> agendamentos = snapshot.requireData;
              agendamentos = agendamentos.where((element) => element.data.isSameDate(selectedDate)).toList();
              agendamentos.sort((a, b) => a.data.compareTo(b.data));

              return Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        tooltip: "Data atual",
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime.now();
                            datas = getDaysInBeteween(
                              selectedDate.subtract(const Duration(days: 1)),
                              selectedDate.add(const Duration(days: 1)),
                            );
                          });
                        },
                        icon: const Icon(Icons.today),
                      ),
                      IconButton(
                        tooltip: "Reagendar todos",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buidMassAgendar(context, agendamentos),
                          ).then(
                            (value) {
                              setState(() {});
                            },
                          );
                        },
                        icon: const Icon(Icons.calendar_month),
                      ),
                      IconButton(
                        tooltip: "Atualizar",
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
                  floatingActionButton: IconButton(
                    icon: const Icon(Icons.add, size: 36),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CadastroPage(),
                        ),
                      );
                    },
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedDate = selectedDate.subtract(const Duration(days: 1));
                                  datas = getDaysInBeteween(
                                    selectedDate.subtract(const Duration(days: 1)),
                                    selectedDate.add(const Duration(days: 1)),
                                  );
                                });
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),

                            // Dates List
                            Container(
                              width: 300,
                              child: Center(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: datas.length,
                                  itemBuilder: (context, index) {
                                    DateTime data = datas[index];

                                    return Container(
                                      decoration: BoxDecoration(
                                          color: (selectedDate.isSameDate(data)) ? palette["blue"] : Colors.transparent,
                                          border: Border.all(color: Colors.white),
                                          borderRadius: const BorderRadius.all(Radius.circular(45))),
                                      width: 100,
                                      height: 30,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDate = data;
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            DateFormat("dd/MM/yyy").format(data),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Forward Button
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedDate = selectedDate.add(const Duration(days: 1));
                                    datas = getDaysInBeteween(
                                      selectedDate.subtract(const Duration(days: 1)),
                                      selectedDate.add(
                                        const Duration(days: 1),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.arrow_forward)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: agendamentos.length,
                          itemBuilder: (context, index) {
                            Agendamento agendamento = agendamentos[index];
                            Cliente cliente = agendamento.cliente;

                            return ListTile(
                              title: Text(cliente.nome),
                              tileColor: corAgenda[agendamento.status]?.withOpacity(0.3),
                              leading: Icon(
                                Icons.circle,
                                color: corAgenda[agendamento.status],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextIcon(
                                    icon: Icons.person,
                                    text: "Resp: ${cliente.responsavel}",
                                    width: 500,
                                  ),
                                  TextIcon(
                                    icon: Icons.calendar_month,
                                    text: DateFormat("dd/MM/yyyy HH:mm").format(agendamento.data),
                                    width: 200,
                                  ),
                                  TextIcon(icon: Icons.wysiwyg, text: agendamento.status.name),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(BootstrapIcons.whatsapp),
                                        tooltip: "Notificar",
                                        onPressed: () {
                                          String dataText = DateFormat("dd/MM/yyyy").format(agendamento.data);
                                          String timeText = DateFormat("HH:mm").format(agendamento.data);

                                          bool hasResp = (cliente.responsavel != "N/A");
                                          var mensagem = (hasResp)
                                              ? "Olá ${cliente.responsavel}!\nGostaria de confirmar o atendimento com Vitor Aragão para ${cliente.nome} no dia $dataText às $timeText?"
                                              : "Olá ${cliente.nome}!\nGostaria de confirmar o atendimento com Vitor Aragão no dia $dataText às $timeText?";

                                          var whatsappUrl = "whatsapp://send?phone=+55${cliente.telefone}"
                                              "&text=${Uri.encodeComponent(mensagem)}";
                                          try {
                                            if (Platform.isAndroid || Platform.isIOS) {
                                              launchUrl(Uri.parse(whatsappUrl));
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Unsupported platform"),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Unable to open whatsapp"),
                                              ),
                                            );
                                          }
                                        },
                                      ),

                                      IconButton(
                                        icon: Icon(LucideIcons.video),
                                        tooltip: "Chamada de Video",
                                        onPressed: () async {
                                          String? meet_url = await createGoogleMeetEvent(agendamento);
                                          if (meet_url != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(content: Text("Google meet criado")));
                                            launchUrl(Uri.parse(meet_url));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Não foi possivle criar a reunião")));
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash),
                                        tooltip: "Deletar",
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => _buildDeletar(context, agendamento),
                                          ).then(
                                            (value) {
                                              setState(
                                                () {},
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      if (agendamento.status != STATUS_AGENDAMENTO.FINALIZADO)
                                        IconButton(
                                          icon: const Icon(LucideIcons.calendar),
                                          tooltip: "Reagendar",
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => _buildReagendar(agendamento),
                                            ).then(
                                              (value) {
                                                setState(() {});
                                              },
                                            );
                                          },
                                        ),
                                      // Editar
                                      IconButton(
                                          tooltip: "Editar Agendamento",
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => _buildEditar(context, agendamento),
                                            ).then(
                                              (value) {
                                                setState(
                                                  () {},
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(LucideIcons.pencil)),
                                      if (agendamento.status != STATUS_AGENDAMENTO.FINALIZADO)
                                        IconButton(
                                          icon: const Icon(LucideIcons.check),
                                          tooltip: "Finalizar agendamento",
                                          onPressed: () {
                                            AgendamentosDB().mudarStatus(agendamento.id, STATUS_AGENDAMENTO.FINALIZADO);
                                            setState(() {});
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => buildAgendaDisplay(context, agendamento),
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ));
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

Widget buildAgendaDisplay(BuildContext context, Agendamento agendamento) {
  Cliente cliente = agendamento.cliente;
  return Dialog(
    child: InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(top: 25, bottom: 0, left: 0, right: 0),
        label: Text(
          "Agendamento",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  buildDisplay("Data", DateFormat("dd/MM/yyyy HH:mm").format(agendamento.data), Icons.person,
                      width: 150),
                  const SizedBox(height: 10),
                  buildDisplay("Valor", "R\$ ${agendamento.valor}", CupertinoIcons.money_dollar),
                  const SizedBox(height: 10),
                  buildDisplay("Plano", agendamento.plano, CupertinoIcons.money_dollar),
                  const SizedBox(height: 10),
                  buildDisplay("STATUS", agendamento.status.name, CupertinoIcons.archivebox_fill),
                ],
              ),
              Column(
                children: [
                  buildDisplay("Nome", cliente.nome, Icons.person, width: 150),
                  const SizedBox(height: 10),
                  buildDisplay("Responsavel", cliente.responsavel, Icons.person, width: 150),
                  const SizedBox(height: 10),
                  buildDisplay("CPF", cliente.cpf, Icons.person, width: 150),
                  const SizedBox(height: 10),
                  buildDisplay("Telefone", cliente.telefone, Icons.phone, width: 150),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEditar(BuildContext context, Agendamento agendamento) {
  // Cliente
  TextEditingController cliente = TextEditingController(text: agendamento.cliente.nome);

  // Agendamento
  DateTime dataAgendamento = agendamento.data;
  MoneyMaskedTextController valor = MoneyMaskedTextController(
      decimalSeparator: ",", thousandSeparator: ".", leftSymbol: "R\$ ", initialValue: agendamento.valor);
  TextEditingController plano = TextEditingController(text: agendamento.plano);
  TextEditingController status = TextEditingController(text: agendamento.status.name);
  GlobalKey<FormState> _key = GlobalKey<FormState>();

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
                width: 250,
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

  return Dialog(
    child: InputDecorator(
      decoration: const InputDecoration(
        label: Text(
          "Editar Agendamento",
          style: TextStyle(fontSize: 24),
        ),
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 520,
        child: StatefulBuilder(
          builder: (context, setState) => Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 15),
                // Paciente
                DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchDelay: Duration.zero,
                    itemBuilder: (context, item, isSelected) {
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                  asyncItems: (text) async {
                    List<Cliente> clientes = await ClientesDB().getAll();

                    return clientes.map((e) => e.nome).toList();
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                        labelText: "Paciente", hintText: "Selecione o paciente", border: OutlineInputBorder()),
                  ),
                  itemAsString: (item) => item,
                  selectedItem: agendamento.cliente.nome,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        cliente.text = value;
                      });
                    }
                  },
                ),
                CustomButton(
                  height: 30,
                  child: const Text("Cadastrar novo paciente"),
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
                ),
                const SizedBox(height: 10),
                // Agendamento
                InputDecorator(
                  decoration: const InputDecoration(
                    label: Text(
                      "Agendamento",
                      style: TextStyle(fontSize: 24),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CustomInput(
                        label: "valor",
                        icon: CupertinoIcons.money_dollar,
                        controller: valor,
                        width: 250,
                        type: TextInputType.number,
                      ),
                      const SizedBox(height: 5),
                      selectorPlano(),
                      const SizedBox(height: 5),
                      Container(
                        width: 250,
                        height: 70,
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
                            "Data",
                            DateFormat("dd/MM/yyyy").format(dataAgendamento),
                            Icons.calendar_month,
                            width: 250,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 250,
                        height: 70,
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
                            "Horário",
                            DateFormat("HH:mm").format(dataAgendamento),
                            Icons.hourglass_empty,
                            width: 250,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildTipoSelector(status),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                CustomButton(
                  child: const Text(
                    "Editar",
                    style: TextStyle(fontSize: 24),
                  ),
                  height: 50,
                  width: 100,
                  onTap: () async {
                    if (_key.currentState!.validate()) {
                      Cliente? client = await ClientesDB().getByName(cliente.text);

                      if (client != null) {
                        Map<String, Object> novo = {
                          "cliente": client.toJson(),
                          "data": dataAgendamento.millisecondsSinceEpoch,
                          "valor": valor.numberValue,
                          "status": status.text,
                          "plano": plano.text
                        };

                        AgendamentosDB().update(agendamento.id, novo);

                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Cliente não atualizado(Não encontrado) ...")));
                        Map<String, Object> novo = {
                          "cliente": agendamento.cliente.toJson(),
                          "data": dataAgendamento.millisecondsSinceEpoch,
                          "valor": valor.numberValue,
                          "status": status.text,
                          "plano": plano.text
                        };

                        AgendamentosDB().update(agendamento.id, novo);

                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildDeletar(BuildContext context, Agendamento agendamento) {
  return Dialog(
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        width: 250,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Deseja mesmo deletar este agendamento?",
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  child: const Text(
                    "SIM",
                    style: TextStyle(fontSize: 32, color: Colors.red),
                  ),
                  width: 100,
                  onTap: () {
                    AgendamentosDB().deletarAgendamento(agendamento.id);
                    Navigator.of(context).pop();
                  },
                ),
                CustomButton(
                  width: 100,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "NÃO",
                    style: TextStyle(fontSize: 32, color: Colors.green),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget _buildReagendar(Agendamento agendamento) {
  // Cliente cliente = agendamento.cliente;

  return StatefulBuilder(
    builder: (context, setState) {
      return Dialog(
        child: InputDecorator(
          decoration: const InputDecoration(
            label: Text(
              "Reagendar sessão",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          child: Container(
            width: 180,
            height: 160,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
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
                              agendamento.data =
                                  agendamento.data.copyWith(day: data.day, month: data.month, year: data.year);
                            });
                          }
                        },
                        icon: buildDisplay(
                            "Data", DateFormat("dd/MM/yyyy").format(agendamento.data), Icons.calendar_month),
                      ),
                    ),
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
                              agendamento.data = agendamento.data.copyWith(
                                hour: time.hour,
                                minute: time.minute,
                              );
                            });
                          }
                        },
                        icon: buildDisplay(
                            "Horário", DateFormat("HH:mm").format(agendamento.data), Icons.hourglass_bottom),
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  child: const Text("Reagendar"),
                  height: 50,
                  onTap: () async {
                    Map<String, Object> novoAgendamento = {
                      "cliente": agendamento.cliente.toJson(),
                      "data": agendamento.data.millisecondsSinceEpoch,
                      "valor": agendamento.valor,
                      "status": STATUS_AGENDAMENTO.AGENDADO.name,
                      "plano": agendamento.plano
                    };

                    AgendamentosDB().insertAgendamento(novoAgendamento);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buidMassAgendar(BuildContext context, List<Agendamento> agendamentos) {
  if (agendamentos.isEmpty) {
    return Dialog(
      child: InputDecorator(
        decoration: const InputDecoration(
          label: Text(
            "Reagendar sessão",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: Container(
          width: 180,
          height: 100,
          child: Center(
            child: Column(
              children: [
                const Text("Não existem agendamentos hoje"),
                CustomButton(
                  child: Text("Ok"),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return Dialog(
        child: InputDecorator(
          decoration: const InputDecoration(
            label: Text(
              "Reagendar sessão",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          child: Container(
            width: 180,
            height: 100,
            child: Column(
              children: [
                const Text(
                  "Reagendar todas sessões para semana que vem?",
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.red),
                      ),
                      width: 100,
                      height: 50,
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomButton(
                      child: const Text(
                        "Reagendar",
                        style: TextStyle(color: Colors.green),
                      ),
                      width: 100,
                      height: 50,
                      onTap: () async {
                        for (var agendamento in agendamentos) {
                          DateTime novaData = agendamento.data.add(const Duration(days: 7));
                          Map<String, Object> novoAgendamento = {
                            "cliente": agendamento.cliente.toJson(),
                            "data": novaData.millisecondsSinceEpoch,
                            "valor": agendamento.valor,
                            "status": STATUS_AGENDAMENTO.AGENDADO.name,
                            "plano": agendamento.plano
                          };

                          AgendamentosDB().insertAgendamento(novoAgendamento);
                        }
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
