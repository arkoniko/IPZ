import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipz_parkinghunter/components/map_waypoint.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseReference database = FirebaseDatabase(
    databaseURL:
        'https://ipzparkinghunter-30f5b-default-rtdb.europe-west1.firebasedatabase.app/',
  ).reference().child("Markery");
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isFullscreen = false; // State variable for fullscreen mode
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

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
        addMarker(_markers, position);
        setState(() {});
      }
    });
  }

  // Method to zoom in the map
  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  // Method to zoom out the map
  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
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
                'version 1.0.9',
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
          _buildGoogleMap(context),
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
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    double bottomPadding =
        _isFullscreen ? 0 : MediaQuery.of(context).size.height * 0.1;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: _isFullscreen ? 0 : MediaQuery.of(context).size.height * 0.4,
      child: ClipRRect(
        borderRadius:
            _isFullscreen ? BorderRadius.zero : BorderRadius.circular(20),
        child: GoogleMap(
          zoomControlsEnabled: false, // Disable default zoom controls
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

            // Dodaj punkt do bazy danych Firebase
            database.push().set({
              'latitude': position.latitude,
              'longitude': position.longitude,
            }).then((_) {
              // Po dodaniu punktu do bazy danych, dodaj go również do lokalnego zbioru _markers i odśwież mapę
              addMarker(_markers, position);
              setState(() {});
            }).catchError((error) => print('Error: $error'));
          },
        ),
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
              addMarker(_markers, position);
              setState(() {});
            })
      ],
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error('Location permissions are permanently denied');
    }

    // When permissions are granted, get the current position
    Position position = await Geolocator.getCurrentPosition();
    _setUserLocationMarker(position);
  }

  void _setUserLocationMarker(Position position) {
    LatLng userPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      // Add a new marker to the map for the user's current position
      _markers.add(Marker(
        markerId: MarkerId(
            userPosition.toString()), // Unique identifier for the marker
        position: userPosition, // The location of the marker
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarker, // Default pin icon
      ));

      // Optionally, move the camera to the user's current position
      _mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    });
  }
}
