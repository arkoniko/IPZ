import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  bool _isFullscreen = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  String? _selectedMarkerId;

  bool _addingFreeParking = false;

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
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
      bool isFreeParking = value['isFreeParking'] ?? false;
      LatLng position = LatLng(latitude, longitude);
      if (isFreeParking) {
        addFreeParkingMarker(_markers, position, event.snapshot.key!);
      } else {
        addMarker(_markers, position, event.snapshot.key!);
      }
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

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    LatLng userPosition = LatLng(position.latitude, position.longitude);

    Marker userLocationMarker = Marker(
      markerId: MarkerId('userLocation'),
      position: userPosition,
      infoWindow: InfoWindow(title: 'Twoja lokalizacja'),
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      _markers.add(userLocationMarker);
      _mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    });
  } catch (e) {
    print('Failed to get current position: $e');
    _showErrorSnackBar('Failed to get current position');
  }
}

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void addCustomMarker(LatLng position) async {
    try {
      // Load the custom marker icon from assets
      BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'lib/images/marker_green.png', // Adjust the path to your custom icon
      );

      // Add the custom marker to the set of markers
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Miejsce wolne',
            snippet: '*tbd*',
          ),
          icon: customIcon,
          onTap: () {
            // Set the selected marker ID when the marker is tapped
            setState(() {
              _selectedMarkerId = position.toString();
            });
            print("Selected marker ID: $_selectedMarkerId");
          },
        ),
      );

      // Optionally, move the camera to the long-pressed position
      _mapController.animateCamera(CameraUpdate.newLatLng(position));

      setState(() {});
    } catch (e) {
      print('Error loading custom marker icon: $e');
      // Handle the error, for example, show a default marker or log the error.
    }
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
                'version 1.1.6',
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
          _buildGoogleMap(),
          _buildZoomControls(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(!_isFullscreen),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      left: 20,
      bottom: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: _zoomIn,
            child: Icon(Icons.add),
            heroTag: 'zoomIn',
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            mini: true,
            onPressed: _zoomOut,
            child: Icon(Icons.remove),
            heroTag: 'zoomOut',
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            mini: true,
            onPressed: _goToUserLocation,
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
            borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(20),
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
                DatabaseReference newMarkerRef = database.push();
                newMarkerRef.set({
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'isFreeParking': _addingFreeParking
                }).then((_) {
                  if (_addingFreeParking) {
                    addFreeParkingMarker(_markers, position, newMarkerRef.key!);
                  } else {
                    addMarker(_markers, position, newMarkerRef.key!);
                  }
                  setState(() {
                    _addingFreeParking = false; // Reset flag after adding marker
                  });
                }).catchError((error) => print('Error: $error'));
              },
              onLongPress: (LatLng position) {
                addCustomMarker(position);
              },
            ),
          ),
        ),
        _selectedMarkerId != null ? _buildDeleteButton() : SizedBox(),
      ],
    ),
  );
}


  Widget _buildToggleFreeParkingButton() {
  return FloatingActionButton(
    onPressed: () {
      setState(() {
        _addingFreeParking = !_addingFreeParking;
      });
    },
    child: Icon(_addingFreeParking ? Icons.local_parking : Icons.car_repair),
    backgroundColor: _addingFreeParking ? Colors.green : Colors.red,
  );
}


  Widget _buildFullscreenButton() {
    return FloatingActionButton(
      onPressed: _toggleFullscreen,
      child: Icon(Icons.fullscreen),
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
            backgroundColor: Colors.greenAccent,
            onTap: () {
                  addCurrentLocationAsFreeParking();
            }),
        SpeedDialChild(
          child:  Icon(Icons.event_busy_outlined),
          label: 'Zajete miejsce parkingowe',
          backgroundColor: Colors.redAccent,
          onTap: () {
                  addCurrentLocationAsOccupiedParking();
            }
        )
      ],
    );
  }

  Widget _buildDeleteButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_selectedMarkerId != null) {
          if (_selectedMarkerId!.startsWith("LatLng")) {
            removeCustomMarker(_selectedMarkerId!);
          } else {
            removeMarker(_selectedMarkerId!);
          }
          _selectedMarkerId = null;
          setState(() {});
        }
      },
      child: Icon(Icons.delete),
      backgroundColor: Colors.red,
    );
  }

  void removeMarker(String markerId) {
    // Remove the marker locally
    _markers.removeWhere((marker) => marker.markerId.value == markerId);
    // Remove the marker from the Firebase Realtime Database
    database.child(markerId).remove().then((_) {
      print("Marker removed from the database.");
      setState(() {
        // Trigger a refresh to update the markers on all devices
        loadMarkers();
      });
    }).catchError((error) => print('Error: $error'));
  }

  void removeCustomMarker(String markerId) {
    _markers.removeWhere((marker) => marker.markerId.value == markerId);
    setState(() {});
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _setUserLocationMarker(position);
    } catch (e) {
      print('Failed to get current position: $e');
    }
  }

  void _setUserLocationMarker(Position position) async {
    LatLng userPosition = LatLng(position.latitude, position.longitude);

    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'lib/images/pingarrow.png');

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(userPosition.toString()),
        position: userPosition,
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
        icon: customIcon,
      ));

      _mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    });
  }

  void addFreeParkingMarker(Set<Marker> markers, LatLng position, String markerId) async {
  try {
    // Załaduj niestandardową ikonę znacznika z zasobów aplikacji
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'lib/images/marker_green.png', // Ścieżka do niestandardowej ikony znacznika
    );

    // Dodaj znacznik z niestandardową ikoną do zestawu znaczników
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(
          title: 'Wolne miejsce parkingowe',
        ),
        icon: customIcon,
        onTap: () {
          setState(() {
            _selectedMarkerId = markerId;
          });
          print("Selected marker ID: $_selectedMarkerId");
        },
      ),
    );
    setState(() {}); // Odśwież stan, aby zaktualizować UI
  } catch (e) {
    print('Error loading custom marker icon: $e');
    // Obsłuż błąd, np. pokazując domyślny znacznik lub rejestrując błąd
  }
}
void changeMarkerToFreeParking() async {
  if (_selectedMarkerId != null) {
    // Pobierz aktualne dane znacznika
    database.child(_selectedMarkerId!).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        // Bezpieczne rzutowanie na Map<dynamic, dynamic>
        Map<dynamic, dynamic> markerData = event.snapshot.value as Map<dynamic, dynamic>;
        LatLng position = LatLng(markerData['latitude'], markerData['longitude']);

        // Aktualizuj znacznik w Firebase
        database.child(_selectedMarkerId!).update({
          'isFreeParking': true,
        }).then((_) {
          // Usuń stary znacznik i dodaj nowy z aktualizacją
          _markers.removeWhere((marker) => marker.markerId.value == _selectedMarkerId);
          addFreeParkingMarker(_markers, position, _selectedMarkerId!);
          setState(() {});
        });
      }
    }).catchError((error) {
      print('Error updating marker: $error');
      _showErrorSnackBar('Failed to update marker');
    });
  }
}

Widget _buildChangeToFreeParkingButton() {
    return FloatingActionButton(
      onPressed: changeMarkerToFreeParking,
      child: Icon(Icons.change_circle),
      backgroundColor: Colors.blue,
    );
  }


Widget _buildFloatingActionButtons(bool showFullscreenButton) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (_isFullscreen) _buildMinimizeButton(),

      // Przycisk do zmiany stanu znacznika
      if (_selectedMarkerId != null) _buildChangeToFreeParkingButton(),

      // Przycisk do dodawania wolnego miejsca parkingowego
      _buildToggleFreeParkingButton(),

      // SpeedDial z dodatkowymi opcjami
      _buildSpeedDial(),

      // Przycisk do przełączania trybu pełnoekranowego
      if (showFullscreenButton) ...[
        SizedBox(height: 20),
        _buildFullscreenButton(),
      ],
    ],
  );
}

void addCurrentLocationAsFreeParking() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    LatLng userPosition = LatLng(position.latitude, position.longitude);
    String markerId = 'freeParking_${DateTime.now().millisecondsSinceEpoch}'; // Unikalny identyfikator

    addFreeParkingMarker(_markers, userPosition, markerId);
  } catch (e) {
    print('Error getting the current location: $e');
    _showErrorSnackBar('Failed to get current position');
  }
}

void addCurrentLocationAsOccupiedParking() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    LatLng userPosition = LatLng(position.latitude, position.longitude);
    String markerId = 'occupiedParking_${DateTime.now().millisecondsSinceEpoch}'; // Unikalny identyfikator

    addMarker(_markers, userPosition, markerId);
  } catch (e) {
    print('Error getting the current location: $e');
    _showErrorSnackBar('Failed to get current position');
  }
}



}
