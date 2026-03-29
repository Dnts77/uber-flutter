// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_flutter/utils/RequestStatus.dart';

class DriverPanel extends StatefulWidget {
  const DriverPanel({super.key});

  @override
  State<DriverPanel> createState() => _DriverPanelState();
}

class _DriverPanelState extends State<DriverPanel> {

  final _streamController = StreamController<QuerySnapshot>.broadcast(); // Controller do stream builder
  FirebaseFirestore db = FirebaseFirestore.instance;

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

  Stream<QuerySnapshot> _addRequestListener(){
    final stream = db.collection("requisicoes").where("status", isEqualTo: RequestStatus.aguardando).snapshots();
    stream.listen((dados){
      _streamController.add(dados);
    });
    return stream;
  }

  @override
  void initState() {
    super.initState();
    _addRequestListener();
  }

  @override
  Widget build(BuildContext context) {

    var loadingMessage = Center(
      child: Column(
        children: [
          Text("Carregando requisições"),
          CircularProgressIndicator(color: Color(0xff1ebbd8))
        ],
      ),
    );
    
    var noDataMessage = Center(
      child: Text("Nenhum dado encontrado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
    );

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
      body: StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return loadingMessage;
              
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError){
                return Text("Erro ao carregar dados");
              }
              else{
                QuerySnapshot? querySnapshot = snapshot.data;
                if(querySnapshot!.docs.isEmpty){
                  return noDataMessage;
                }
                else{
                  return ListView.separated(
                    itemCount: querySnapshot.docs.length,
                    separatorBuilder: (context, index){
                      return Divider(
                        height: 2,
                        color: Colors.grey,
                      );
                    },
                    itemBuilder: (context, index){
                      List<DocumentSnapshot> requests = querySnapshot.docs.toList();
                      DocumentSnapshot item = requests[index];
                      String requestId = item.id;
                      String passengerName = item["passageiro"]["nome"];
                      String street = item["destino"]["rua"];
                      String number = item["destino"]["numero"];

                      return ListTile(
                        title: Text(passengerName),
                        subtitle: Text("Destino: $street, $number"),
                      );
                    },
                  );
                }
              }
              
          }
          
        },
        stream: _streamController.stream,
      ),
    );
  }
}