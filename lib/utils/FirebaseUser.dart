// ignore_for_file: file_names, 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_flutter/model/Usuario.dart';

class FirebaseUser {
  static Future<User> getCurrentUser() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser!;
  }
  static Future<Usuario> getLoggedUserData() async{
    User fbUser = await getCurrentUser();
    String idUsuario = fbUser.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await db.collection("usuarios").doc(idUsuario).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    String tipoUsuario = dados["tipoUsuario"];
    String email = dados["email"];
    String nome = dados["nome"];

    Usuario usuario = Usuario();
    usuario.idUsuario = idUsuario;
    usuario.tipoUsuario = tipoUsuario;
    usuario.email = email;
    usuario.nome = nome;

    return usuario;
    
  }

  static Future<void> updateLocationData(String requestId, double lat, double lon, String userType) async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    Usuario usuario = await getLoggedUserData();
    usuario.latitude = lat;
    usuario.longitude = lon;
    db.collection("requisicoes").doc(requestId).update({
      userType : usuario.toMap()
    });
  }
}