import 'package:clinik/db/cliente_db.dart';
import 'package:clinik/model/cliente.dart';
import 'package:clinik/partials/customButton.dart';
import 'package:clinik/partials/customInput.dart';
import 'package:clinik/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClientesDB().getAll(),
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
              // print(snapshot.error);
              return const Center(
                child: Column(
                  children: [
                    Icon(Icons.error),
                    Text("Unable to load data"),
                  ],
                ),
              );
            } else {
              List<Cliente> clientes = snapshot.requireData;
              clientes.sort(
                (a, b) {
                  if (a.nome.contains("[INATIVO]")) return 1;
                  if (b.nome.contains("[INATIVO]")) return -1;
                  return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
                },
              );
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
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
                body: ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    Cliente cliente = clientes[index];
                    bool hidden = cliente.nome.contains("[INATIVO]");
                    // List<String> splited = cliente.nome.toString().split(" ");

                    return ListTile(
                      title: Text(cliente.nome),
                      subtitle: Text(cliente.responsavel),
                      tileColor: hidden ? Colors.red[900] : Color(0xFF141218),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildDisplayCliente(context, cliente),
                        ).then(
                          (value) {
                            setState(() {});
                          },
                        );
                      },
                      trailing: Container(
                        width: 160,
                        height: 50,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: hidden ? "Exibir" : "Ocultar",
                              onPressed: () async {
                                if (hidden) {
                                  var splited = cliente.nome.split("[INATIVO]");
                                  cliente.nome = splited.last.trimLeft();
                                } else {
                                  cliente.nome = "[INATIVO] ${cliente.nome}";
                                }
                                await ClientesDB().update(cliente.id, cliente.toMap());
                                setState(() {});
                              },
                              icon: Icon(!hidden ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill),
                            ),
                            IconButton(
                              tooltip: "Ligar",
                              onPressed: () async {
                                Uri phoneUri = Uri.parse("tel:${cliente.telefone.trim()}");
                                bool launchable = await canLaunchUrl(phoneUri);
                                if (launchable) {
                                  bool launched = await launchUrl(phoneUri);
                                  if (!launched) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Unable to make call"),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Unable to make call"),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.phone),
                            ),
                            IconButton(
                              tooltip: "Editar",
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _buildEditarCliente(context, cliente),
                                ).then(
                                  (value) {
                                    setState(() {});
                                  },
                                );
                              },
                              icon: const Icon(CupertinoIcons.pencil),
                            ),
                            IconButton(
                              tooltip: "Deletar",
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => _buildDeletar(context, cliente),
                                ).then(
                                  (value) {
                                    setState(() {});
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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

Widget _buildDeletar(BuildContext context, Cliente cliente) {
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
              "Deseja mesmo deletar este cliente?",
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
                    ClientesDB().deletarCliente(cliente.id);
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

Widget _buildDisplayCliente(BuildContext context, Cliente cliente) {
  return Dialog(
      child: InputDecorator(
    decoration: const InputDecoration(
      label: Text(
        "Cliente",
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      contentPadding: EdgeInsets.all(20),
    ),
    child: Container(
      width: 200,
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              buildDisplay("Nome", cliente.nome, Icons.person, width: 200),
              buildDisplay("Responsável", cliente.responsavel, Icons.person, width: 200),
              buildDisplay("CPF", cliente.cpf, Icons.card_membership, width: 200),
              buildDisplay("Telefone", cliente.telefone, Icons.person, width: 200),
              buildDisplay(
                "Data Nascimento",
                DateFormat("dd/MM/yyyy").format(cliente.dataNasc),
                Icons.calendar_month,
                width: 200,
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _buildEditarCliente(context, cliente);
                      },
                    );
                  },
                  icon: const Text("Editar"))
            ],
          ),
        ],
      ),
    ),
  ));
}

Widget buildAddCliente(BuildContext context) {
  TextEditingController nome = TextEditingController();
  TextEditingController telefone = TextEditingController();
  TextEditingController cpf = TextEditingController();
  TextEditingController responsavel = TextEditingController();
  bool hasResponsavel = false;

  DateTime dataNasc = DateTime.now();

  return Dialog(child: StatefulBuilder(
    builder: (context, setState) {
      return InputDecorator(
        decoration: const InputDecoration(
          label: Text(
            "Adicionar Cliente",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          contentPadding: EdgeInsets.all(20),
        ),
        child: Container(
          width: 200,
          height: 370,
          child: Column(
            children: [
              Column(
                children: [
                  Column(
                    children: [
                      CustomInput(label: "Nome", icon: Icons.person, controller: nome, width: 300),
                      const SizedBox(width: 15),
                      Row(
                        children: [
                          Column(
                            children: [
                              Checkbox(
                                value: hasResponsavel,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      hasResponsavel = value!;
                                    },
                                  );
                                },
                              ),
                              const Text(
                                "Responsavel",
                              ),
                            ],
                          ),
                          if (hasResponsavel)
                            CustomInput(
                              label: "Responsavel",
                              icon: Icons.person,
                              controller: responsavel,
                              width: 200,
                            ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 0),
                  Column(
                    children: [
                      CustomInput(
                          label: "CPF",
                          icon: Icons.person,
                          controller: cpf,
                          width: 300,
                          formatter: MaskTextInputFormatter(mask: "###.###.###-##", filter: {"#": RegExp(r'[0-9]')})),
                      const SizedBox(width: 15),
                      CustomInput(
                          label: "Telefone",
                          icon: Icons.phone,
                          controller: telefone,
                          width: 300,
                          formatter: MaskTextInputFormatter(mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')})),
                    ],
                  ),
                  Container(
                    width: 300,
                    height: 100,
                    child: IconButton(
                      onPressed: () async {
                        DateTime? data = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1910, 1, 1),
                          lastDate: DateTime.now().add(
                            const Duration(days: 150),
                          ),
                        );
                        if (data != null) {
                          setState(() {
                            dataNasc = data;
                          });
                        }
                      },
                      icon: buildDisplay(
                        "Data Nascimento",
                        DateFormat("dd/MM/yyyy").format(dataNasc),
                        Icons.calendar_month,
                        width: 300,
                      ),
                    ),
                  ),
                ],
              ),
              CustomButton(
                child: const Icon(Icons.add_card),
                height: 50,
                onTap: () async {
                  if (nome.text.isNotEmpty) {
                    Map<String, Object> client = {
                      "nome": nome.text,
                      "responsavel": hasResponsavel ? responsavel.text : "N/A",
                      "cpf": cpf.text,
                      "telefone": telefone.text,
                      "dataNasc": dataNasc.millisecondsSinceEpoch
                    };

                    // print("Trying to add");
                    ClientesDB().insertCliente(client);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha o campo nome")));
                  }
                },
              )
            ],
          ),
        ),
      );
    },
  ));
}

Widget _buildEditarCliente(BuildContext context, Cliente cliente) {
  TextEditingController nome = TextEditingController(text: cliente.nome);
  TextEditingController telefone = TextEditingController(text: cliente.telefone);
  TextEditingController cpf = TextEditingController(text: cliente.cpf);
  TextEditingController responsavel = TextEditingController(text: cliente.responsavel);
  DateTime dataNasc = cliente.dataNasc;

  return Dialog(child: StatefulBuilder(
    builder: (context, setState) {
      return InputDecorator(
        decoration: const InputDecoration(
          label: Text(
            "Editar Cliente",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          contentPadding: EdgeInsets.all(20),
        ),
        child: Container(
          width: 200,
          height: 350,
          child: Column(
            children: [
              Column(
                children: [
                  Column(
                    children: [
                      CustomInput(
                        label: "Nome",
                        icon: Icons.person,
                        controller: nome,
                        width: 300,
                        readOnly: true,
                      ),
                      const SizedBox(width: 15),
                      CustomInput(
                        label: "Responsavel",
                        icon: Icons.person,
                        controller: responsavel,
                        width: 300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  Column(
                    children: [
                      CustomInput(
                          label: "CPF",
                          icon: Icons.person,
                          controller: cpf,
                          width: 300,
                          formatter: MaskTextInputFormatter(mask: "###.###.###-##", filter: {"#": RegExp(r'[0-9]')})),
                      const SizedBox(width: 15),
                      CustomInput(
                          label: "Telefone",
                          icon: Icons.phone,
                          controller: telefone,
                          width: 300,
                          formatter: MaskTextInputFormatter(mask: "(##) #####-####", filter: {"#": RegExp(r'[0-9]')})),
                    ],
                  ),
                  Container(
                    width: 300,
                    height: 100,
                    child: IconButton(
                      onPressed: () async {
                        DateTime? data = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1910, 1, 1),
                          lastDate: DateTime.now().add(
                            const Duration(days: 150),
                          ),
                        );
                        if (data != null) {
                          setState(() {
                            dataNasc = data;
                          });
                        }
                      },
                      icon: buildDisplay(
                        "Data Nascimento",
                        DateFormat("dd/MM/yyyy").format(dataNasc),
                        Icons.calendar_month,
                        width: 300,
                      ),
                    ),
                  ),
                ],
              ),
              CustomButton(
                child: const Icon(Icons.add_card),
                height: 50,
                onTap: () async {
                  if (nome.text.isNotEmpty) {
                    Map<String, Object> client = {
                      "nome": nome.text,
                      "responsavel": responsavel.text,
                      "cpf": cpf.text,
                      "telefone": telefone.text,
                      "dataNasc": dataNasc.millisecondsSinceEpoch
                    };

                    ClientesDB().update(cliente.id, client);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha o campo nome")));
                  }
                },
              )
            ],
          ),
        ),
      );
    },
  ));
}
