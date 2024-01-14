import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipz_parkinghunter/components/map_waypoint.dart';
import 'package:firebase_database/firebase_database.dart';


//Widget that will be response for every logic changes eg. displaying waypoints, path

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};

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
      drawer: BurgerMenu(), //assigned BurgerMenu into our MainPage
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
                      addMarker(_markers, position);
                        //setState refreshing map, making waypoints visible
                        setState(() {}); 
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
}
