import 'package:eazyride_mobile/components/role.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'dart:convert';  
import 'package:eazyride_mobile/theme/hex_color.dart';

class WelcomeToOurApp extends StatefulWidget {
  const WelcomeToOurApp({super.key});

  @override
  State<WelcomeToOurApp> createState() => _WelcomeToOurAppState();
}

class _WelcomeToOurAppState extends State<WelcomeToOurApp> {
  MapboxMap? mapboxMap;
  geo.Position? _currentPosition;
  bool _isLoading = true;

  @override
  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken('pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      _currentPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      Get.snackbar(
        'Location Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    _addCurrentLocationMarker();
  }

  Future<void> _addCurrentLocationMarker() async {
    if (_currentPosition == null || mapboxMap == null) return;

    final point = {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [_currentPosition!.longitude, _currentPosition!.latitude],
      },
      "properties": {},
    };

    await mapboxMap!.style.addSource(
      GeoJsonSource(
        id: "current-location",
        data: jsonEncode(point), // Convert to GeoJSON string
      ),
    );

    await mapboxMap!.style.addLayer(
      CircleLayer(
        id: "current-location-layer",
        sourceId: "current-location",
        circleColor: Colors.blue.value, // Use integer value directly
        circleRadius: 8.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            mapOptions: MapOptions(
              
              pixelRatio: MediaQuery.of(context).devicePixelRatio,
              //style: "mapbox://styles/mapbox/streets-v11",
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  _currentPosition?.longitude ?? 30.0619,
                  _currentPosition?.latitude ?? -1.9403,
                ),
              ),
              zoom: 15.0,
            ),
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
              children: [
                Image.asset(
                  'assets/images/WelcomeScreen.png'
                  ),

                const SizedBox(height: 20.0),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Have a better sharing experience',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 80),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RoleSelectionScreen()));
                  },//SignUp
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: HexColor("#EDAE10"),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Create an account',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RoleSelectionScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: HexColor("#FFFFFF"),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HexColor("#EDAE10"),
                          style: BorderStyle.solid,
                          strokeAlign: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            color: HexColor("#EDAE10"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    mapboxMap?.dispose();
    super.dispose();
  }
}
