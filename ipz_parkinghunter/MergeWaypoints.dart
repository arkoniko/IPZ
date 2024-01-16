import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';
import 'package:firebase_database/firebase_database.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DatabaseReference database = FirebaseDatabase(
    databaseURL: 'https://ipzparkinghunter-30f5b-default-rtdb.europe-west1.firebasedatabase.app/',
  ).reference().child("Markery");
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isFullscreen = false; // Zmienna stanu dla trybu pełnoekranowego
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  String? _selectedMarkerId; // Zmienna przechowująca aktualnie wybrane ID

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMarkers();
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
                DatabaseReference newMarkerRef = database.push();
                newMarkerRef.set({
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                }).then((_) {
                  // Po dodaniu punktu do bazy danych, dodaj go również do lokalnego zbioru _markers i odśwież mapę
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
          },
        ),
      ],
    );
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
                'version 1.0.8',
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
          _isFullscreen ? _buildMinimizeButton() : _buildFullscreenButton(),
        ],
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }
  Widget _buildDeleteButton() {
  return Positioned(
    left: 20,
    top: MediaQuery.of(context).padding.top +80,
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

}
