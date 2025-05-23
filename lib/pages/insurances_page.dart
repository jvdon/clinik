import 'package:clinik/db/insurance_db.dart';
import 'package:clinik/model/insurance.dart';
import 'package:clinik/partials/customButton.dart';
import 'package:clinik/partials/customInput.dart';
import 'package:flutter/material.dart';

class InsurancesPage extends StatefulWidget {
  const InsurancesPage({super.key});

  @override
  State<InsurancesPage> createState() => _InsurancesPageState();
}

class _InsurancesPageState extends State<InsurancesPage> {
  @override
  Widget build(BuildContext context) {
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
              List<Insurance> planos = snapshot.requireData;
              planos.sort(
                (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
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
                      builder: (context) {
                        TextEditingController nome = TextEditingController();
                        return Dialog(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              label: Text(
                                "Adicionar plano de saúde",
                                style: TextStyle(fontSize: 24, color: Colors.white),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                            child: Container(
                              width: 200,
                              height: 130,
                              child: Column(
                                children: [
                                  const SizedBox(height: 2),
                                  CustomInput(label: "Nome", icon: Icons.card_membership, controller: nome),
                                  CustomButton(
                                    child: const Icon(Icons.add_card),
                                    onTap: () async {
                                      if (nome.text.isNotEmpty) {
                                        InsuranceDB().insertInsurance({"nome": nome.text});
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Preencha o campo nome")),
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ).then(
                      (value) {
                        setState(() {});
                      },
                    );
                  },
                ),
                body: ListView.builder(
                  itemCount: planos.length,
                  itemBuilder: (context, index) {
                    Insurance insurance = planos[index];
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 16,
                      ),
                      title: Text(insurance.nome),
                      trailing: IconButton(
                        onPressed: () {
                          InsuranceDB().deletarInsurance(insurance.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
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
