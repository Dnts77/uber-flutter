import 'package:flutter/material.dart';
import 'package:uber_flutter/screens/driver_panel.dart';
import 'package:uber_flutter/screens/home_screen.dart';
import 'package:uber_flutter/screens/passenger_panel.dart';
import 'package:uber_flutter/screens/sign_up_screen.dart';

class Routes{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_)=>HomeScreen());
      case "/cadastro":
        return MaterialPageRoute(builder: (_)=> SignUpScreen());
      case "/painel-motorista":
        return MaterialPageRoute(builder: (_)=> DriverPanel());
      case "/painel-passageiro":
        return MaterialPageRoute(builder: (_)=> PassengerPanel());
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