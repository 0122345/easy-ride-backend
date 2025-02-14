import 'package:eazyride_mobile/components/drawer.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:eazyride_mobile/home/search_screen.dart';
import 'package:eazyride_mobile/notifications/home.dart';
import 'package:eazyride_mobile/transport/request/driver/ride_request.dart';
import 'package:eazyride_mobile/transport/request/passenger/ride_request.dart';
import 'package:eazyride_mobile/transport/ride/request_ride.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyDrawerController>(
      builder: (_) => ZoomDrawer(
        controller: _.zoomDrawerController,
        menuScreen: const MenuScreen(),
        mainScreen: const HomeMap(),
        borderRadius: 24.0,
        showShadow: true,
        angle: 12.0,
        drawerShadowsBackgroundColor: Colors.grey[300]!,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        openCurve: Curves.fastOutSlowIn,
        menuBackgroundColor: Colors.white,
      ),
    );
  }
}

class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  int _selectedIndex = 0;
  final List<IconData> _iconList = [
    Icons.home,
    Icons.favorite,
    Icons.report,
    Icons.local_offer,
    Icons.person,
  ];
  final pageController = PageController(initialPage: 0);
  final MyDrawerController controller = Get.find<MyDrawerController>();
  GoogleMapController? mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocationServices();
  }

  Future<void> _initLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    _updateMarkerAndCamera();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateMarkerAndCamera();
        _sendLocationToServer(position);
      });
    });
  }

  void _updateMarkerAndCamera() {
    if (_currentPosition != null) {
      LatLng latLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: latLng,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16.0),
        ),
      );
    }
  }

  Future<void> _sendLocationToServer(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('_SERVER_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'userType': 'passenger',
          'timestamp': DateTime.now().toIso8601String(),
          'userId': 'USER_ID',
        }),
      );
    } catch (e) {
      print('Error sending location data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(-1.9441, 30.0444),
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
          Column(
            children: [
              _buildTopBar(context),
              const Spacer(),
              _buildBottomBar(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: GetBuilder<MyDrawerController>(
                builder: (controller) {
                  return Center(
                    child: IconButton(
                      onPressed: () => controller.toggleDrawer(),
                      icon: Icon(controller.isDrawerOpen
                          ? Icons.close_rounded
                          : Icons.menu),
                      color: Colors.black,
                    ),
                  );
                },
              ),

              //const Icon(Icons.menu, color: Colors.black),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationSearchScreen())),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeNotifications())),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: () {
                //RideRequestScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: RideState(), // or pass existing RideState instance
                      child: const RideRequestP(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child:
                  const Text('Rental', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Where would you go?',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestForRentScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: const Text('Transport'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RideRequestScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      side: BorderSide(color: Colors.amber),
                    ),
                  ),
                  child: const Text('Delivery',
                      style: TextStyle(color: Colors.amber)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return AnimatedBottomNavigationBar(
      icons: _iconList,
      activeIndex: _selectedIndex,
      gapLocation: GapLocation.end,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 0,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      activeColor: Colors.amber,
      inactiveColor: Colors.grey,
      backgroundColor: const Color.fromARGB(255, 148, 93, 93),
      iconSize: 30.0, // Size of the icons
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _positionStream?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}
