// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';


class PassengerPanel extends StatefulWidget {
  const PassengerPanel({super.key});

  @override
  State<PassengerPanel> createState() => _PassengerPanelState();
}

class _PassengerPanelState extends State<PassengerPanel> {

  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(-23.472297, -46.530986),
  );

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

  // Método do mapa
  void _onMapCreated(GoogleMapController controller){
    _mapController.complete(controller);
  }

  //Recuperando última localização 
  Future<void> _getLastKnownPositon() async{
    Position? position = await Geolocator.getLastKnownPosition();
    setState(() {
      if(position != null){
        _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(_cameraPosition);
      }
    });
  
  }

  //Listener da localização
  void _addLocationListener(){
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position){
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(_cameraPosition);
    });
    
  }


  //Permissões de geolocalização
  Future<void> _checkPermissions() async{
    bool servicesEnabled;
    LocationPermission permission;
    servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if(!servicesEnabled){
      return Future.error("Os serviços de localização estão desativados");
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Permissões negadas");
      }
    }
    if(permission == LocationPermission.deniedForever){
      return Future.error("Permissões totalmente negadas. Impossível prosseguir");
    }
  }


  //Movimentação da camera  
  Future<void> _moveCamera(CameraPosition cameraPosition) async{
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition)
    );
  }

  //Inicializando os métodos do localização
  Future<void> _initLocation() async{
    await _checkPermissions();
    await _getLastKnownPositon();
    _addLocationListener();
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel passageiro"),
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
      body: Container(
        padding: EdgeInsets.only(bottom: 2),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _cameraPosition,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}