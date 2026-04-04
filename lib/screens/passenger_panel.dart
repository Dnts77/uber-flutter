// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uber_flutter/model/Destiny.dart';
import 'package:uber_flutter/model/Request.dart';
import 'package:uber_flutter/model/Usuario.dart';
import 'package:uber_flutter/utils/FirebaseUser.dart';
import 'package:uber_flutter/utils/RequestStatus.dart';


class PassengerPanel extends StatefulWidget {
  const PassengerPanel({super.key});

  @override
  State<PassengerPanel> createState() => _PassengerPanelState();
}

class _PassengerPanelState extends State<PassengerPanel> {

  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _destinyController = TextEditingController(text: "Rua Força Pública, 89"); //Controller do botão "Chamar Uber"
  String? _requestId;

  final CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(-23.472297, -46.530986),
  );

  final Set<Marker> _markers = {};

  Map<String, dynamic>? _requestData;

  //Local do passageiro
  Position? _passengerLocation;

  //Controles de exibição
  bool _showDestinyAddressBox = true;
  String _buttonText = "Chamar Uber";
  Color _buttonColor = Color(0xff1ebbd8);
  VoidCallback? _buttonFunction;

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
     if( _requestId != null && _requestId!.isNotEmpty){
      FirebaseUser.updateLocationData(
        _requestId!,
        position.latitude,
        position.longitude
      );
     }else{
      _notCalledUberStatus();
     }
     
      setState(() {
          _passengerLocation = position;
      });
     
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
    //await _getLastKnownPositon();
    _addLocationListener();
  }

  //Exibindo o marcador do passageiro
  Future<void> _showPassengerMarker(Position local) async{
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Marker passengerMarker = Marker(
      markerId: MarkerId("marcador-passageiro"),
      position: LatLng(local.latitude, local.longitude),
      infoWindow: InfoWindow(
        title: "Meu local"
      ),
      icon: await BitmapDescriptor.asset(
        width: 70,
        height: 70,
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "assets/imgs/passageiro.png"
      )
    );
    setState(() {
      _markers.add(passengerMarker);
    });
  }


  //Chamando uber
  Future<void> _callUber() async{
    String destinyAddress = _destinyController.text;
    if(destinyAddress.isNotEmpty){
      List<Location> locationConvert = await locationFromAddress(destinyAddress);
      List<Placemark> addressList = await placemarkFromCoordinates(locationConvert[0].latitude, locationConvert[0].longitude);
        if(addressList.isNotEmpty){
          Placemark address = addressList[0];
          Destiny destiny = Destiny();
          destiny.cidade = address.administrativeArea!;
          destiny.cep = address.postalCode!;
          destiny.bairro = address.subLocality!;
          destiny.rua = address.thoroughfare!;
          destiny.numero = address.subThoroughfare!;
          destiny.latitude = locationConvert[0].latitude;
          destiny.longitude = locationConvert[0].longitude;

          String addressConfirmation;
          addressConfirmation = "\n Cidade: ${destiny.cidade}";
          addressConfirmation += "\n Rua: ${destiny.rua}, ${destiny.numero}";
          addressConfirmation += "\n Bairro: ${destiny.bairro}";
          addressConfirmation += "\n CEP: ${destiny.cep}";

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Confirmação do endereço"),
                content: Text(addressConfirmation),
                contentPadding: EdgeInsets.all(16),
                actions: [
                  TextButton(
                    onPressed: ()=> Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: (){
                      //salvando a requisição
                      _saveRequest(destiny);
                      Navigator.pop(context);
                    },
                    child: Text("Confirmar", style: TextStyle(color: Colors.green)),
                  ),

                ],
              );
            },
          );
        }
    }
  }

  
  //Salvando a requisição de chamar uber
  Future<void> _saveRequest( Destiny destino) async{
    Request request = Request();
    Usuario passageiro = await FirebaseUser.getLoggedUserData();
    passageiro.latitude = _passengerLocation!.latitude;
    passageiro.longitude = _passengerLocation!.longitude;
    request.destino = destino;
    request.passageiro = passageiro;
    request.status = RequestStatus.aguardando;

    FirebaseFirestore db = FirebaseFirestore.instance;
    
    //Salvando requisição
    db.collection("requisicoes").doc(request.id).set(request.toMap());

    //Salvando requisição ativa
    Map<String, dynamic> activeRequestData = {};
    activeRequestData["id_requisicao"] = request.id;
    activeRequestData["id_usuario"] = passageiro.idUsuario;
    activeRequestData["status"] = RequestStatus.aguardando;

   db.collection("requisicao_ativa").doc(passageiro.idUsuario).set(activeRequestData);

   _waitingStatus();

  }

  //Mudando o botão
  void _changeMainButton(String text, Color color, VoidCallback? function){
    setState(() {
      _buttonText = text;
      _buttonColor = color;
      _buttonFunction = function;
    });
  }

  //Status do Uber
  void _notCalledUberStatus(){
    _showDestinyAddressBox = true;
    _changeMainButton("Chamar Uber", Color(0xff1ebbd8), (){_callUber();});
     
      if(_passengerLocation == null) return;
     
     Position position = Position(
      latitude: _passengerLocation!.latitude,
      longitude: _passengerLocation!.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0
     );

     _showPassengerMarker(position);
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(cameraPosition);
  }

  //Status -> Aguardando
  void _waitingStatus(){
     _showDestinyAddressBox = false;
    _changeMainButton("Cancelar", Colors.red, (){_cancelUber();});

    double passengerLat = _requestData!["passageiro"]["latitude"];
    double passengerLon = _requestData!["passageiro"]["longitude"];
    Position position = Position(
      latitude: passengerLat,
      longitude: passengerLon,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0
     );

     _showPassengerMarker(position);
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(cameraPosition);
  }
  //Status -> A caminho
  void _onTheWay(){
    _showDestinyAddressBox = false;
    _changeMainButton("Motorista a caminho", Colors.grey, null);
  }

  //Cancelar uber
  Future<void> _cancelUber() async{
    User user = await FirebaseUser.getCurrentUser();
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").doc(_requestId).update({
      "status" : RequestStatus.cancelada
    }).then((_){
      db.collection("requisicao_ativa").doc(user.uid).delete();
    });
  }

  //Adicionando listener às requisições ativas
  Future<void> _addActiveRequestListener() async{
    User user = await FirebaseUser.getCurrentUser();
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await db.collection("requisicao_ativa").doc(user.uid).get();

    if(documentSnapshot.data() != null){
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      _requestId = data["id_requisicao"];
      _addRequestListener(_requestId!);
    }else{
      _notCalledUberStatus();
    }
  }

  Future<void> _addRequestListener(String requestId) async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").doc(requestId).snapshots().listen((snapshot){
      if(snapshot.data() != null){
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _requestData = data;
        String status = data["status"];
        _requestId = data["id_requisicao"];

        switch(status){
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


  //init state
  @override
  void initState() {
    super.initState();
    _initLocation();
    _addActiveRequestListener();
    
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
        child: Stack( // Stack widget -> Empilha outros widgets em ordem (últimos sobrepoem os primeiros)
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
            Visibility(
              visible: _showDestinyAddressBox,
              child: Stack(
                children: [
                  Positioned(
                    // Positioned Widget -> posiciona widgets dentro do Stack
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white,
                          ),
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              icon: Container(
                                width: 10,
                                height: 23.2,
                                margin: const EdgeInsets.only(left: 10),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ),
                              hintText: "Meu local",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    // Positioned Widget -> posiciona widgets dentro do Stack
                    top: 55,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white,
                          ),
                          child: TextField(
                            controller: _destinyController,
                            decoration: InputDecoration(
                              icon: Container(
                                width: 10,
                                height: 23.2,
                                margin: const EdgeInsets.only(left: 10),
                                child: const Icon(
                                  Icons.local_taxi,
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "Digite o destino",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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