// ignore_for_file: file_names, unnecessary_getters_setters
import 'package:uber_flutter/model/Destiny.dart';
import 'package:uber_flutter/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String? _id;
  late String _status;
  late Usuario _passageiro;
  late Usuario _motorista;
  late Destiny _destino;
  
  Request(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference ref = db.collection("requisicoes").doc();
    id = ref.id;
  }
  
  String? get id => _id;
  set id(String value) => _id = value;

  String get status => _status;
  set status( String value) => _status = value;

  Usuario get passageiro => _passageiro;
  set passageiro( Usuario value) => _passageiro = value;

  Usuario get motorista => _motorista;
  set motorista( Usuario value) => _motorista = value;

  Destiny get destino => _destino;
  set destino( Destiny value) => _destino = value;

  Map<String, dynamic> toMap(){

    Map<String, dynamic> passengerData = {
      "nome" : passageiro.nome,
      "email" : passageiro.email,
      "tipoUsuario": passageiro.tipoUsuario,
      "idUsuario" : passageiro.idUsuario,
    };

    Map<String, dynamic> destinyData = {
      "rua" : destino.rua,
      "numero" : destino.numero,
      "bairro": destino.bairro,
      "cep" : destino.cep,
      "latitude" : destino.latitude,
      "longitude" : destino.longitude,
    };

    Map<String, dynamic> requestData = {
      "id" : id,
      "status" : status,
      "passageiro" : passengerData,
      "motorista": null,
      "destino" : destinyData,
    };
    return requestData;
  }

}