// ignore_for_file: file_names
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CMarker {
  late LatLng local;
  late String imagePath;
  late String title;
  
  CMarker(this.local, this.imagePath, this.title);
}
