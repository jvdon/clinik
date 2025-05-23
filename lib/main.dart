import 'dart:io';

import 'package:clinik/pages/agendamentos_page.dart';
import 'package:clinik/pages/clientes_page.dart';
import 'package:clinik/pages/insurances_page.dart';
import 'package:clinik/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  if (await googleSignIn.isSignedIn() == false) {
    try {
      final account = await googleSignIn.signIn();
      print(account);
    } catch (error) {
      print('Sign-in error: $error');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currId = 0;
  List<Widget> pages = [
    const AgendamentosPage(),
    const ClientesPage(),
    const InsurancesPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        body: pages[currId],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currId,
          onTap: (value) {
            setState(() {
              currId = value;
            });
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: "Agendamentos"),
            const BottomNavigationBarItem(icon: Icon(LucideIcons.users2), label: "Clientes"),
            const BottomNavigationBarItem(icon: Icon(LucideIcons.creditCard), label: "Planos"),
          ],
        ),
      ),
    );
  }
}
