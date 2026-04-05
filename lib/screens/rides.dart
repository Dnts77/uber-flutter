import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_flutter/model/Usuario.dart';
import 'package:uber_flutter/utils/FirebaseUser.dart';
import 'package:uber_flutter/utils/RequestStatus.dart';

class Rides extends StatefulWidget {
  const Rides(this.requestId, {super.key});

  final String requestId;
  
  @override
  State<Rides> createState() => _RidesState();
}

class _RidesState extends State<Rides> {

  final Completer<GoogleMapController> _mapController = Completer();
  String _statusMessage = "";

  final CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(-23.472543, -46.533509),
  );

  Set<Marker> _markers = {};
  Map<String, dynamic> _requestData = {};
  Position? _driverLocation;
  String? _requestId;
  String _requestStatus = RequestStatus.aguardando;

  

  String _buttonText = "Aceitar corrida";
  Color _buttonColor = Color(0xff1ebbd8);
  VoidCallback? _buttonFunction;

  void _onMapCreated(GoogleMapController controller){
    _mapController.complete(controller);
  }

  
  Future<void> _getLastKnownPositon() async{
    Position? position = await Geolocator.getLastKnownPosition();
    if(position != null){
        _driverLocation = position;
      }
  
  }

  
  void _addLocationListener(){
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position){
     
       if(position != null){
        if (_requestId != null && _requestId!.isNotEmpty) {
          if(_requestStatus != RequestStatus.aguardando){
            FirebaseUser.updateLocationData(
              _requestId!,
              position.latitude,
              position.longitude,
            );
          }else{
            setState(() {
              _driverLocation = position;
            });
            _waitingStatus();
          }
        }
      }
    });
    
  }

   
  Future<void> _moveCamera(CameraPosition cameraPosition) async{
    if(!_mapController.isCompleted)return;

    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition)
    );
  }

  
  Future<void> _initLocation() async{
    await _getLastKnownPositon();
    _addLocationListener();
  }

  
  Future<void> _showDriverMarker(Position local, String icon, String infoWindow) async{
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Marker driverMarker = Marker(
      markerId: MarkerId(icon),
      position: LatLng(local.latitude, local.longitude),
      infoWindow: InfoWindow(
        title: infoWindow
      ),
      icon: await BitmapDescriptor.asset(
        width: 70,
        height: 70,
        ImageConfiguration(devicePixelRatio: pixelRatio),
        icon
      )
    );
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == icon);
      _markers.add(driverMarker);
    });
  }

   void _changeMainButton(String text, Color color, VoidCallback? function){
    setState(() {
      _buttonText = text;
      _buttonColor = color;
      _buttonFunction = function;
    });
  }


  //Recuperando a requisição
  Future<void> _recoverRequest() async{
    String requestId  = widget.requestId;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await db.collection("requisicoes").doc(requestId).get(); 
  }

  //Adicionando Listener da requisição
  Future<void>_addRequestListener() async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    
    db.collection("requisicoes").doc(_requestId).snapshots().listen((snapshot){
      if(snapshot.data() != null){
        _requestData = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _requestStatus = data["status"];

        switch(_requestStatus){
          case RequestStatus.aguardando:
            _waitingStatus();
            break;
          case RequestStatus.aCaminho:
            _onTheWay();
            break;
          case RequestStatus.viagem:

            break;
          case RequestStatus.finalizada:

            break;
        }

      }
    });
  }

  void _waitingStatus(){
    _changeMainButton("Aceitar corrida", Color(0xff1ebbd8), (){acceptRide();});

    if(_driverLocation != null){
      double driverLatitude = _driverLocation!.latitude;
      double driverLongitude = _driverLocation!.longitude;
      Position position = Position(
        latitude: driverLatitude,
        longitude: driverLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      if (_driverLocation == null) return;
      _showDriverMarker(position, "assets/imgs/motorista.png", "Motorista");

      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 19,
      );

      _moveCamera(cameraPosition);
    }
  }

  Future<void> _moveCameraBounds(LatLngBounds latLngBounds) async{
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        latLngBounds,
        100
      )
    );
  }

  //Status de "A caminho"
  void _onTheWay(){
    _changeMainButton("Iniciar corrida", Color(0xff1ebbd8), (){
      _initRide();
    });
    _statusMessage = "A caminho do passageiro";
    double passengerLatitude = _requestData["passageiro"]["latitude"];
    double passengerLongitude = _requestData["passageiro"]["longitude"];

    double driverLatitude = _requestData["motorista"]["latitude"];
    double driverLongitude = _requestData["motorista"]["longitude"];

    _showTwoMarkers(
      LatLng(driverLatitude, driverLongitude),
      LatLng(passengerLatitude, passengerLongitude)
    );


    double nLat, nLon, sLat, sLon;
    if(driverLatitude <= passengerLatitude){
      sLat = driverLatitude;
      nLat = passengerLatitude;
    }else{
      sLat = passengerLatitude;
      nLat = driverLatitude;
    }

    if(driverLongitude <= passengerLongitude){
      sLon = driverLongitude;
      nLon = passengerLongitude;
    }else{
      sLon = passengerLongitude;
      nLon = driverLongitude;
    }

    Future.delayed(Duration(milliseconds: 300) , (){
      _moveCameraBounds(
        LatLngBounds(
          northeast: LatLng(nLat, nLon),
          southwest: LatLng(sLat, sLon),
        )
      );
    }); 
  }


  //Iniciando corrida
  void _initRide(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").doc(_requestId).update({
      "origem" : {
        "latitude" : _requestData["motorista"]["latitude"],
        "longitude" : _requestData["motorista"]["longitude"],
      },
      "status" : RequestStatus.viagem
    });
    
    String passengerId = _requestData["passageiro"]["idUsuario"];
    db.collection("requisicao_ativa").doc(passengerId).update({
      "status": RequestStatus.viagem
    });

    String driverId = _requestData["motorista"]["idUsuario"];
    db.collection("requisicao_ativa_motorista").doc(driverId).update({
      "status": RequestStatus.viagem
    });
  }

  //Exibindo dois marcadores
  Future<void> _showTwoMarkers(LatLng latLng1, LatLng latLng2) async{
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> markersList = {};
    Marker marker1 = Marker(
      markerId: MarkerId("motorista"),
      position: LatLng(latLng1.latitude, latLng1.longitude),
      infoWindow: InfoWindow(
        title: "Local do motorista"
      ),
      icon: await BitmapDescriptor.asset(
        width: 70,
        height: 70,
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "assets/imgs/motorista.png"
      )
    );
    markersList.add(marker1);

    Marker marker2 = Marker(
      markerId: MarkerId("passageiro"),
      position: LatLng(latLng2.latitude, latLng2.longitude),
      infoWindow: InfoWindow(
        title: "Local do passageiro"
      ),
      icon: await BitmapDescriptor.asset(
        width: 70,
        height: 70,
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "assets/imgs/passageiro.png"
      )
    );
   markersList.add(marker2);
   setState(() {
     _markers = markersList;
   });
  }

  //Aceitando corrida
  Future<void> acceptRide() async{

    Usuario motorista = await FirebaseUser.getLoggedUserData();
    motorista.latitude = _driverLocation!.latitude;
    motorista.longitude = _driverLocation!.longitude;

    FirebaseFirestore db = FirebaseFirestore.instance;
    String requestId = _requestData["id"];
    db.collection("requisicoes").doc(requestId).update({
     "motorista": motorista.toMap(),
     "status": RequestStatus.aCaminho,
    }).then((_){
      String passengerId = _requestData["passageiro"]["idUsuario"];
      db.collection("requisicao_ativa").doc(passengerId).update({
        "status": RequestStatus.aCaminho,
      });
      
      String driverId = motorista.idUsuario;
      db.collection("requisicao_ativa_motorista").doc(driverId).set({
        "id_requisicao": requestId,
        "id_usuario": driverId,
        "status": RequestStatus.aCaminho,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    _requestId = widget.requestId;
    //_recoverRequest();
    _addRequestListener();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel de corrida - $_statusMessage"),  
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 2),
        child: Stack( 
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 25,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: _buttonFunction,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        _buttonColor,
                      ),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.fromLTRB(32, 16, 32, 16)
                      )
                    ),
                    child: Text(
                      _buttonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}