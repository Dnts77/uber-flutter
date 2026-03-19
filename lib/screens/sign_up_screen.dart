// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uber_flutter/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController _controllerEmail = TextEditingController(); // Controlador do email
  final TextEditingController _controllerNome = TextEditingController(); // Controlador do nome
  final TextEditingController _controllerSenha = TextEditingController(); // Controlador da senha
  bool _userType = false; //tipo de passageiro -> falso passageiro, verdadeiro motorista 
  String _errorMessage = "";

  
  //Validação dos campos
  void _validateFields(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){
      
      if(email.isNotEmpty && email.contains("@")){
        
        if(senha.isNotEmpty && senha.length > 6 ){

          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;
          usuario.tipoUsuario = usuario.checkTypeUser(_userType);

          _signUpUser( usuario );
        }

        else{

          setState(() {
            _errorMessage = "Preencha a senha!";
          });

        }
      }
      
      else{
        setState(() {
          _errorMessage = "Preencha o email!";
        });
      }
    }
    
    else{
      setState(() {
        _errorMessage = "Preencha o nome!";
      });

    }
  }


  // Cadastrando o usuário
  void _signUpUser(Usuario usuario){

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    auth.createUserWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
      )
      .then((firebaseUser){
        db.collection("usuarios").doc(firebaseUser.user!.uid).set(usuario.toMap());
        switch(usuario.tipoUsuario){
          case "motorista":
          return Navigator.pushNamedAndRemoveUntil(context, "/painel-motorista", (_)=>false);
          case "passageiro":
          return Navigator.pushNamedAndRemoveUntil(context, "/painel-passageiro", (_)=>false);
        }
      }
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.stretch,
              children: [
                //TextField do Nome
                TextField(
                  controller: _controllerNome,
                  cursorColor: const Color(0xff1ebbd8),
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Seu nome",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.white
                      )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    )
                  ),
                ),
                
                //TextField do email
                TextField(
                  controller: _controllerEmail,
                  cursorColor: const Color(0xff1ebbd8),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.white
                      )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    )
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  cursorColor: const Color(0xff1ebbd8),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xff1ebbd8)
                      )
                    ),
                  ),
                ),


                //Switch para passageiro/motorista
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text("Passageiro"),
                      Switch(value: _userType, activeThumbColor:Color(0xff1ebbd8), onChanged: (bool valor){
                        setState(() {
                          _userType = valor;
                        });
                      }),
                      Text("Passageiro")
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    onPressed: (){
                      _validateFields();
                    },
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xff1ebbd8),
                      ),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.fromLTRB(32, 16, 32, 16)
                      )
                    ),
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 20),),
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}