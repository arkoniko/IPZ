import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        addMarker(_markers, position);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(247, 247, 247, 247),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromARGB(247, 15, 101, 158),
        title: Text(
          'version 1.0.2',
          style: TextStyle(
            fontFamily: 'Arial',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      drawer: BurgerMenu(),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 15, 221, 176),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(53.447242736816406, 14.492215156555176),
                      zoom: 10,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _mapController = controller;
                      });
                    },
                    markers: _markers,
                    onTap: (position) {
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
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              //tu zawartosc
            ),
          ),
        ],
      ),
    );
  }

  void addMarker(Set<Marker> markers, LatLng position) {
    markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      ),
    );
  }
}
