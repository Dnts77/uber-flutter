import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_flutter/firebase_options.dart';
import 'package:uber_flutter/routes/routes.dart';
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
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xff47474f),
          shadowColor: Color(0xff546e7a),
          elevation: 3,
          foregroundColor: Colors.white,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xff1ebbd8),
          selectionHandleColor: Color(0xff1ebbd8)
        ),
        secondaryHeaderColor: Color(0xff546e7a)
      ),
      initialRoute: "/",
      onGenerateRoute: Routes.generateRoute,
      
    )
  );
}

