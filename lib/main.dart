import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_flutter/firebase_options.dart';
import 'package:uber_flutter/screens/home_screen.dart';

void main() async {

  // Inicialização do Firebase 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );


  runApp(
    MaterialApp(
      home: HomeScreen(),
      title: "Uber",
      debugShowCheckedModeBanner: false,
      
    )
  );
}

