import 'package:google_maps_flutter/google_maps_flutter.dart';


//Marker on the map, contains position, title which is 'miejsce zajete' and default icon
void addMarker(Set<Marker> markers, LatLng position) {

  //to confirm its working correctly
  print("Waypoint added at: $position");  
  markers.add(
    Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(
        title: 'Miejsce zajęte',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  );
}