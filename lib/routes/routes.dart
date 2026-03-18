import 'package:flutter/material.dart';
import 'package:uber_flutter/screens/home_screen.dart';
import 'package:uber_flutter/screens/sign_up_screen.dart';

class Routes{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_)=>HomeScreen());
      case "/cadastro":
        return MaterialPageRoute(builder: (_)=> SignUpScreen());
      default:
        return _routeError();
    }
  }

  static Route<dynamic> _routeError(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada"),
          ),
          body: Center(
            child: Text("Tela não encontrada!"),
          )
        );

      }
    );
  }

}