// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverPanel extends StatefulWidget {
  const DriverPanel({super.key});

  @override
  State<DriverPanel> createState() => _DriverPanelState();
}

class _DriverPanelState extends State<DriverPanel> {

  List<String> menuItems = [
    "Deslogar", "Configurações"
  ];


  // Menu de PopUp
  void _menuItemChoice(String escolha){
    switch(escolha){
      case "Deslogar":
        _userSignOut();
        break;
      case "Configurações":

        break;
    }
  }

  //Deslogando o usuário
  Future<void> _userSignOut() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel motorista"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menuItemChoice,
            itemBuilder: (context){
              
              return menuItems.map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList();
            },
          )
        ],
      ),
      body: Container(),
    );
  }
}