import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/components/drawer.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:eazyride_mobile/home/search_screen.dart';
import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:eazyride_mobile/notifications/home.dart';
import 'package:eazyride_mobile/settings/home.dart';
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
import 'package:web_socket_channel/web_socket_channel.dart';


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
    final Set<Marker> _driverMarkers = {};
    WebSocketChannel? _webSocket;
    Timer? _locationUpdateTimer;
    final double _nearbyRadius = 100; // 100 meters

    @override
    void initState() {
      super.initState();
      _initLocationServices();
      _initWebSocket();
      _startLocationUpdates();
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

    void _initWebSocket() {
      _webSocket = WebSocketChannel.connect(
        Uri.parse('ws://easy-ride-backend-xl8m.onrender.com/api/ws'),
      );
    
      _webSocket!.stream.listen((message) {
        final data = jsonDecode(message);
        _updateDriverMarkers(data);
      });
    }

    void _startLocationUpdates() {
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_currentPosition != null) {
          _sendLocationToServer(_currentPosition!);
          _fetchNearbyDrivers();
        }
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
          Uri.parse('https://easy-ride-backend-xl8m.onrender.com/api/location/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'userType': 'passenger',
            'userId': 'PASSENGER_ID', // Replace with actual passenger ID
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      } catch (e) {
        print('Error sending location: $e');
      }
    }

    Future<void> _fetchNearbyDrivers() async {
      try {
        final response = await http.get(
          Uri.parse(
            'https://easy-ride-backend-xl8m.onrender.com/api/api/drivers/nearby?lat=${_currentPosition!.latitude}&lng=${_currentPosition!.longitude}&radius=$_nearbyRadius'
          ),
        );

        if (response.statusCode == 200) {
          final List<dynamic> drivers = jsonDecode(response.body);
          _updateDriverMarkers(drivers);
        }
      } catch (e) {
        print('Error fetching nearby drivers: $e');
      }
    }

    void _updateDriverMarkers(List<dynamic> drivers) {
      setState(() {
        _driverMarkers.clear();
      
        // Add passenger marker
        if (_currentPosition != null) {
          _driverMarkers.add(
            Marker(
              markerId: const MarkerId('passenger'),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(title: 'You'),
            ),
          );
        }

        // Add driver markers
        for (var driver in drivers) {
          _driverMarkers.add(
            Marker(
              markerId: MarkerId('driver_${driver['id']}'),
              position: LatLng(
                driver['latitude'],
                driver['longitude'],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title: 'Driver ${driver['name']}',
                snippet: 'Rating: ${driver['rating']}',
              ),
            ),
          );
        }
      });
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
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(-1.9441, 30.0444),
                zoom: 15,
              ),
              markers: _driverMarkers, // Use the combined markers set
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
                      child: const Homepage(),
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
                          builder: (context) => Homepage())),
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
       MaterialPageRoute(builder: (_) => const HomeMap()),
       MaterialPageRoute(builder: (_) => const Homepage()),
       MaterialPageRoute(builder: (_) =>  PrivacyPolicyScreen()),
       MaterialPageRoute(builder: (_) => const HomeNotifications()),
       MaterialPageRoute(builder: (_) => const HomeSettings()),
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
      activeColor: Colors.amber,
      inactiveColor: Colors.grey,
      backgroundColor: const Color.fromARGB(255, 148, 93, 93),
      iconSize: 30.0,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _positionStream?.cancel();
    _webSocket?.sink.close();
    _locationUpdateTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }
}

