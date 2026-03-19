// ignore_for_file: file_names, unnecessary_getters_setters

class Usuario {
  late String _idUsuario;
  late String _nome;
  late String _email;
  late String _senha;
  late String _tipoUsuario;
 
  String get idUsuario => _idUsuario;
  set idUsuario(String value) => _idUsuario = value;

  String get nome => _nome;
  set nome( String value) => _nome = value;

  String get email => _email;
  set email( String value) => _email = value;

  String get senha => _senha;
  set senha( String value) => _senha = value;

  String get tipoUsuario => _tipoUsuario;
  set tipoUsuario( String value) => _tipoUsuario = value;


  Usuario();

  String checkTypeUser(bool usertype){
    return usertype ? "motorista" : "passageiro";
  }

  //Converte para map
  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome" : nome,
      "email" : email,
      "tipoUsuario": tipoUsuario
    };
    return map;
  }

}