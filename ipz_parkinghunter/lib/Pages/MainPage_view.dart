import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipz_parkinghunter/components/map_waypoint.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

//add marker and remove marker are in this file, need to be reorganised in future
//also check Widget _builddeletebutton right now

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //create database refevrence
  final DatabaseReference database = FirebaseDatabase(
    databaseURL:
        'https://ipzparkinghunter-30f5b-default-rtdb.europe-west1.firebasedatabase.app/',
  ).reference().child("Markery");

  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isFullscreen = false; // State variable for fullscreen mode
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  String? _selectedMarkerId; // selected waypoint id

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      // Your logic after state change
    });
  }

  @override
  void initState() {
    super.initState();
    loadMarkers();
    _determinePosition();
  }

  Future<void> loadMarkers() async {
    database.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? value = event.snapshot.value as Map?;

      if (value != null) {
        double latitude = value['latitude'];
        double longitude = value['longitude'];
        LatLng position = LatLng(latitude, longitude);
        addMarker(_markers, position, event.snapshot.key!);
        setState(() {});
      }
    });
  }

  void addMarker(Set<Marker> markers, LatLng position, String markerId) {
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(
          title: 'Miejsce zajęte',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          setState(() {
            _selectedMarkerId = markerId;
          });
          print("Selected marker ID: $_selectedMarkerId");
        },
      ),
    );
  }

  // Method to zoom in the map
  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  // Method to zoom out the map
  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng userPosition = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    } catch (e) {
      print('Failed to get current position: $e');
      // Show a SnackBar with an error message
      _showErrorSnackBar('Failed to get current position');
    }
  }

//bar at the bottom of our site, saying whats wrong?
  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(247, 247, 247, 247),
      appBar: _isFullscreen
          ? null
          : AppBar(
              elevation: 0.0,
              backgroundColor: Color.fromARGB(247, 15, 101, 158),
              title: Text(
                'version 1.1.0',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
      drawer: _isFullscreen ? null : BurgerMenu(),
      body: Stack(
        children: [
          _buildGoogleMap(), //removed context for now
          _buildZoomControls(), // Always show zoom controls
          _buildFloatingActionButtons(!_isFullscreen),
          if (_isFullscreen) _buildMinimizeButton(),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      left: 20, // Adjust the position as needed
      bottom:
          MediaQuery.of(context).size.height * 0.5, // Center on the left side
      child: Column(
        children: [
          FloatingActionButton(
            mini: true, // for smaller buttons
            onPressed: _zoomIn,
            child: Icon(Icons.add),
            heroTag: 'zoomIn',
          ),
          SizedBox(height: 20), // Space between the buttons
          FloatingActionButton(
            mini: true, // for smaller buttons
            onPressed: _zoomOut,
            child: Icon(Icons.remove),
            heroTag: 'zoomOut',
          ),
          SizedBox(height: 20), // Space between the buttons and the new button
          FloatingActionButton(
            mini: true,
            onPressed: _goToUserLocation, // Add this callback
            child: Icon(Icons.my_location),
            heroTag: 'userLocation',
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: _isFullscreen ? 0 : MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  _isFullscreen ? BorderRadius.zero : BorderRadius.circular(20),
              child: GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(53.447242736816406, 14.492215156555176),
                  zoom: 10,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _markers,
                onTap: (position) {
                  // Your logic related to the map

                  //add point to current map -> add point to database
                  DatabaseReference newMarkerRef = database.push();
                  newMarkerRef.set({
                    'latitude': position.latitude,
                    'longitude': position.longitude,
                  }).then((_) {
                    addMarker(_markers, position, newMarkerRef.key!);
                    setState(() {});
                  }).catchError((error) => print('Error: $error'));
                },
              ),
            ),
          ),
          _selectedMarkerId != null ? _buildDeleteButton() : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(bool showFullscreenButton) {
    // Return a Column containing the SpeedDial button and conditionally the fullscreen button
    return Positioned(
      right: 20,
      bottom: MediaQuery.of(context).padding.bottom + 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildSpeedDial(),
          if (showFullscreenButton) ...[
            SizedBox(height: 20), // Spacing between buttons, adjust as needed
            _buildFullscreenButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildFullscreenButton() {
    return Positioned(
      left: 20,
      bottom: MediaQuery.of(context).padding.bottom + 20,
      child: FloatingActionButton(
        onPressed: _toggleFullscreen,
        child: Icon(Icons.fullscreen),
      ),
    );
  }

  Widget _buildMinimizeButton() {
    return Positioned(
      right: 20,
      top: MediaQuery.of(context).padding.top + 20,
      child: FloatingActionButton(
        onPressed: _toggleFullscreen,
        child: Icon(Icons.close),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      openCloseDial: isDialOpen,
      backgroundColor: Color.fromARGB(247, 15, 101, 158),
      overlayColor: Colors.grey,
      overlayOpacity: 0.5,
      spacing: 15,
      spaceBetweenChildren: 15,
      closeManually: true,
      children: [
        SpeedDialChild(
          child: Icon(Icons.share_rounded),
          label: 'Udostepnij',
          backgroundColor: Color.fromARGB(247, 15, 101, 158),
          onTap: () {
            print('Test udostepniania');
          },
        ),
        SpeedDialChild(
            child: Icon(Icons.gps_fixed_rounded),
            label: 'Wolne miejsce parkingowe',
            backgroundColor: Colors.redAccent,
            onTap: () {
              LatLng position = LatLng(53.447242736816406, 14.492215156555176);
              addMarker(_markers, position, "fakeId");
              setState(() {});
            })
      ],
    );
  }

  //deleting button appears under the map!! need to be fixed
  Widget _buildDeleteButton() {
    return Positioned(
      left: 20,
      top: MediaQuery.of(context).padding.top + 80,
      child: FloatingActionButton(
        onPressed: () {
          if (_selectedMarkerId != null) {
            removeMarker(_selectedMarkerId!);
            _selectedMarkerId = null;
            setState(() {});
          }
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
    );
  }

  void removeMarker(String markerId) {
    // Znajdź i usuń marker z lokalnego zbioru
    _markers.removeWhere((marker) => marker.markerId.value == markerId);

    // Usuń marker z bazy danych
    database.child(markerId).remove().then((_) {
      print("Marker removed from the database.");

      // Odśwież mapę po usunięciu markera
      setState(() {});
    }).catchError((error) => print('Error: $error'));
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return; // Optionally, handle this case by setting a default location
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return; // Optionally, handle this case by setting a default location
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return; // Optionally, handle this case by setting a default location
    }

    // When permissions are granted, get the current position
    try {
      Position position = await Geolocator.getCurrentPosition();
      _setUserLocationMarker(position);
    } catch (e) {
      print('Failed to get current position: $e');
      // Handle the error by setting a default location, or leave as is
    }
  }

  void _setUserLocationMarker(Position position) async {
    LatLng userPosition = LatLng(position.latitude, position.longitude);

    // Load the custom marker icon from assets
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'lib/images/car2.png');

    setState(() {
      // Add a new marker to the map for the user's current position
      _markers.add(Marker(
        markerId: MarkerId(userPosition.toString()),
        position: userPosition,
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
        icon: customIcon,
      ));

      // Optionally, move the camera to the user's current position
      _mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    });
  }
}
