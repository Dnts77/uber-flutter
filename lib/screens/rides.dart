import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Rides extends StatefulWidget {
  const Rides(this.requestId, {super.key});

  final String requestId;
  
  @override
  State<Rides> createState() => _RidesState();
}

class _RidesState extends State<Rides> {

  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(-23.472297, -46.530986),
  );

  final Set<Marker> _markers = {};

  bool _showDestinyAddressBox = true;
  String _buttonText = "Aceitar corrida";
  Color _buttonColor = Color(0xff1ebbd8);
  VoidCallback? _buttonFunction;

  void _onMapCreated(GoogleMapController controller){
    _mapController.complete(controller);
  }

  
  Future<void> _getLastKnownPositon() async{
    Position? position = await Geolocator.getLastKnownPosition();
    setState(() {
      if(position != null){
        _showPassengerMarker(position);
        _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(_cameraPosition);
      }
    });
  
  }

  
  void _addLocationListener(){
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position){
      _showPassengerMarker(position);
      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19,
        );
        _moveCamera(_cameraPosition);
    });
    
  }

   
  Future<void> _moveCamera(CameraPosition cameraPosition) async{
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition)
    );
  }

  
  Future<void> _initLocation() async{
    await _getLastKnownPositon();
    _addLocationListener();
  }

  
  Future<void> _showPassengerMarker(Position local) async{
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Marker passengerMarker = Marker(
      markerId: MarkerId("marcador-motorista"),
      position: LatLng(local.latitude, local.longitude),
      infoWindow: InfoWindow(
        title: "Meu local"
      ),
      icon: await BitmapDescriptor.asset(
        width: 70,
        height: 70,
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "assets/imgs/motorista.png"
      )
    );
    setState(() {
      _markers.add(passengerMarker);
    });
  }

   void _changeMainButton(String text, Color color, VoidCallback function){
    setState(() {
      _buttonText = text;
      _buttonColor = color;
      _buttonFunction = function;
    });
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
        title: const Text("Painel de corridas"),  
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