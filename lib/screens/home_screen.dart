// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uber_flutter/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController _controllerEmail = TextEditingController(); // Controlador do email
  final TextEditingController _controllerSenha = TextEditingController(); // Controlador da senha
  String _errorMessage = "";


  //Validação dos campos
  void _validateFields(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

     if(email.isNotEmpty && email.contains("@")){
        
        if(senha.isNotEmpty && senha.length > 6 ){

          Usuario usuario = Usuario();
          usuario.email = email;
          usuario.senha = senha;
          

          _logInUser( usuario );
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


    //Logando usuário
    void _logInUser(Usuario usuario){

      FirebaseAuth auth = FirebaseAuth.instance;
      auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
      ).then((firebaseUser){
        Navigator.pushReplacementNamed(context, "/painel-passageiro"); 
      }).catchError((e){
        _errorMessage = "Erro ao autenticar usuário, verifique os campos novamente";
      });

    }

   
  


  @override
  Widget build(BuildContext context) {
    
    //Interface 
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/imgs/fundo.png"),
            fit: BoxFit.cover
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset("assets/imgs/logo.png", height: 150, width: 200,),
                ),
                TextField(
                  controller: _controllerEmail,
                  cursorColor: const Color(0xff1ebbd8),
                  autofocus: true,
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
                      "Entrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: const Text(
                      "Não tem conta? Cadastre-se!",
                      style: TextStyle(
                        color: Colors.white
                      )
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, "/cadastro");
                    },
                  )
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