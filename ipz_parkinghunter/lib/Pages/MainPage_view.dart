import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipz_parkinghunter/components/map_waypoint.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ipz_parkinghunter/Pages/BurgerMenu.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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

  Widget _buildGoogleMap() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: _isFullscreen ? 0 : MediaQuery.of(context).size.height * 0.4,
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
          },
        ),
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

  Widget _buildSpeedDial(){
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
          onTap: (){
            print('Test udostepniania');
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.gps_fixed_rounded),
          label: 'Wolne miejsce parkingowe',
          backgroundColor: Colors.redAccent,
          onTap: (){
           // LatLng position =  LatLng(53.447242736816406, 14.492215156555176);
           // addMarker(_markers, position);
           //setState(() {
             
           //});
          } 
        )
      ],
    );
  }
}