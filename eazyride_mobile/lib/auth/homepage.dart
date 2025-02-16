import 'package:eazyride_mobile/auth/driver/home_map.dart';
import 'package:eazyride_mobile/auth/driver/search_client_ride.dart';
//import 'package:eazyride_mobile/components/role.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GoogleMapController? mapController;
  Position? currentPosition;
  bool locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => locationPermissionGranted = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() => locationPermissionGranted = false);
    } else if (permission == LocationPermission.deniedForever) {
      setState(() => locationPermissionGranted = false);
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        currentPosition = position;
        locationPermissionGranted = true;
      });
      
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
      } else {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: currentPosition != null 
                ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                : const LatLng(-1.9441, 30.0444),
              zoom: 15,
            ),
            myLocationEnabled: locationPermissionGranted,
            myLocationButtonEnabled: locationPermissionGranted,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideRequestScreen(),
                
              ),
            ),

            child: Icon(Icons.home,
             size: 30,
             color: Colors.amber,
            ),),
          if (!locationPermissionGranted)
            Center(
              child: Dialog(
                backgroundColor: Colors.white,
                shadowColor: Colors.green.shade900,
                child: SizedBox(
                  width: 300,
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset("assets/images/location.png"),
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Enable Your location',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: "Choose your location to start find the",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: "   request around you",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: requestLocationPermission,
                            child: Container(
                              width: 250,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Use my location',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  HomeDriverWrapper(),
                              )
                            ),
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
