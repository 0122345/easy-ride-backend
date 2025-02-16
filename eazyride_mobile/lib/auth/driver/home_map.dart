import 'dart:convert';
import 'dart:async';
import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:eazyride_mobile/settings/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:eazyride_mobile/components/drawer.dart';
import 'package:eazyride_mobile/home/search_screen.dart';
import 'package:eazyride_mobile/notifications/home.dart';
//import 'package:eazyride_mobile/transport/ride/request_ride.dart';
//import 'package:eazyride_mobile/transport/request/driver/ride_request.dart';
import 'package:eazyride_mobile/transport/request/passenger/ride_request.dart';
//import 'package:eazyride_mobile/transport/request/passenger/ride_request_screen.dart';
import 'package:provider/provider.dart';

class HomeDriverWrapper extends StatelessWidget {
  const HomeDriverWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyDrawerController>(
      builder: (_) => ZoomDrawer(
        controller: _.zoomDrawerController,
        menuScreen: const MenuScreen(),
        mainScreen: const HomeDriver(),
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


class HomeDriver extends StatefulWidget {
  const HomeDriver({Key? key}) : super(key: key);

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  final pageController = PageController(initialPage: 0);
  final MyDrawerController controller = Get.find<MyDrawerController>();
  GoogleMapController? mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  WebSocketChannel? _webSocket;
  Timer? _locationTimer;
  static const double _searchRadius = 100.0;
  int _selectedIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.favorite,
    Icons.report,
    Icons.local_offer,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _initLocationServices();
    _initWebSocket();
    _startLocationUpdates();
  }

  Future<void> _initLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    _updateMap();
    _fetchNearbyLocations();
  }

  void _initWebSocket() {
    _webSocket = WebSocketChannel.connect(
      Uri.parse('ws://easy-ride-backend-xl8m.onrender.com/locations/ws'),
    )..stream.listen(_handleLocationUpdate);
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _sendLocationUpdate(),
    );
  }

  Future<void> _sendLocationUpdate() async {
    if (_currentPosition == null) return;

    try {
      await http.post(
        Uri.parse('https://easy-ride-backend-xl8m.onrender.com/api/location/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'radius': _searchRadius,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('Location update failed: $e');
    }
  }

  Future<void> _fetchNearbyLocations() async {
    if (_currentPosition == null) return;
    try {
      final response = await http.get(
        Uri.parse(
          'https://easy-ride-backend-xl8m.onrender.com/api/locations/nearby?lat=${_currentPosition!.latitude}&lng=${_currentPosition!.longitude}&radius=$_searchRadius',
        ),
      );

      if (response.statusCode == 200) {
        final locations = jsonDecode(response.body);
        _updateMarkers(locations);
      }
    } catch (e) {
      print('Failed to fetch nearby locations: $e');
    }
  }

  void _handleLocationUpdate(dynamic data) {
    final locations = jsonDecode(data);
    _updateMarkers(locations);
  }

  void _updateMarkers(List<dynamic> locations) {
    setState(() {
      _markers.clear();

      if (_currentPosition != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ));
      }

      for (var loc in locations) {
        _markers.add(Marker(
          markerId: MarkerId('loc_${loc['id']}'),
          position: LatLng(loc['latitude'], loc['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: loc['name'],
            snippet: 'Distance: ${loc['distance']}m',
          ),
          onTap: () => _showLocationDetails(loc),
        ));
      }
    });
  }

  void _updateMap() {
    if (_currentPosition == null || mapController == null) return;

    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  void _showLocationDetails(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${location['name']}'),
            Text('Distance: ${location['distance']}m'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLocationSelect(location);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 7, 255, 255),
                  ),
                  child: const Text('Accept'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLocationSelect(Map<String, dynamic> location) {
    Get.snackbar(
      'Success',
      'Location selected: ${location['name']}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void _handleNavigation(int index) {
     final routes = [
       MaterialPageRoute(builder: (_) => const HomeDriver()),
       MaterialPageRoute(builder: (_) => const Homepage()),
       MaterialPageRoute(builder: (_) =>  PrivacyPolicyScreen()),
       MaterialPageRoute(builder: (_) => const HomeNotifications()),
       //MaterialPageRoute(builder: (_) => RideRequestScreen()),
     ];

     if (index >= 0 && index < routes.length) {
        setState(() => _selectedIndex = index);
        Navigator.push(context, routes[index]);
     }
  }


  Widget _buildNavigationBar() {
    return AnimatedBottomNavigationBar(
      icons: _iconList,
      activeIndex: _selectedIndex,
      gapLocation: GapLocation.end,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 0,
      onTap: _handleNavigation,
      activeColor: Color.fromARGB(255, 7, 255, 255),
      inactiveColor: const Color.fromARGB(255, 112, 115, 139),
      backgroundColor: const Color.fromARGB(167, 9, 5, 32),
      iconSize: 30.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNavigationBar(),
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
                color: Color.fromARGB(255, 7, 255, 255),
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
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LocationSearchScreen()),
                  ),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 7, 255, 255),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeNotifications()),
                  ),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 7, 255, 255),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: RideState(), // pass RideState instance
                      child: const Homepage(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 7, 255, 255)),
              child: const Text('Request Ride'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _locationTimer?.cancel();
    _webSocket?.sink.close();
    super.dispose();
  }
}
