import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:eazyride_mobile/components/drawer.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:eazyride_mobile/home/search_screen.dart';
import 'package:eazyride_mobile/licence/privacy.dart';
import 'package:eazyride_mobile/notifications/home.dart';
import 'package:eazyride_mobile/settings/home.dart';
import 'package:eazyride_mobile/transport/request/passenger/ride_request.dart';
import 'package:eazyride_mobile/transport/ride/request_ride.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';

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
  MapboxMap? mapboxMap;
  Position? _currentPosition;  WebSocketChannel? _webSocket;
  Timer? _locationUpdateTimer;
  final Set<String> _driverSourceIds = {};
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
    MapboxOptions.setAccessToken('pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw');
    _initLocationServices();
    _initWebSocket();
    _startLocationUpdates();
  }

  Future<void> _initLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _initWebSocket() {
    _webSocket = WebSocketChannel.connect(
      Uri.parse('wss://easy-ride-backend-xl8m.onrender.com/api/ws'),
    );
    
    _webSocket!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _updateDriverMarkers(data);
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket connection closed'),
    );
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (_currentPosition != null) {
          _sendLocationToServer(_currentPosition!);
          _fetchNearbyDrivers();
        }
      },
    );
  }

  Future<void> _sendLocationToServer(Position position) async {
    try {
      _webSocket?.sink.add(jsonEncode({
        'type': 'location_update',
        'data': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }
      }));
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<void> _fetchNearbyDrivers() async {
    // Implementation remains the same
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
      "properties": {"title": "Your Location"}
    };

    await mapboxMap!.style.addSource(
      GeoJsonSource(
        id: "current-location",
        data: jsonEncode(point),
      ),
    );

    await mapboxMap!.style.addLayer(
      CircleLayer(
        id: "current-location-layer",
        sourceId: "current-location",
        circleColor: Colors.blue.value,
        circleRadius: 8.0,
      ),
    );
  }

  Future<void> _updateDriverMarkers(List<dynamic> drivers) async {
    if (mapboxMap == null) return;

    for (String sourceId in _driverSourceIds) {
      await mapboxMap!.style.removeLayer("layer-$sourceId");
      await mapboxMap!.style.removeSource(sourceId);
    }
    _driverSourceIds.clear();

    for (var driver in drivers) {
      final sourceId = "driver-${driver['id']}";
      _driverSourceIds.add(sourceId);

      final point = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [driver['longitude'], driver['latitude']],
        },
        "properties": {
          "name": driver['name'],
          "rating": driver['rating']
        }
      };

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: sourceId, data: jsonEncode(point)),
      );

      await mapboxMap!.style.addLayer(
        CircleLayer(
          id: "layer-$sourceId",
          sourceId: sourceId,
          circleColor: Colors.green.value,
          circleRadius: 8.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            resourceOptions: ResourceOptions(
              accessToken: 'pk.eyJ1IjoibnR3YXJpZmlhY3JlIiwiYSI6ImNtN2UzZjBpbDA1NWMybXM3NDc3bGJlOGYifQ.AXM-Vk9Vq7mzYyoQH5AnMw'
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
                    MaterialPageRoute(builder: (context) => const HomeNotifications()),
                  ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: RideState(),
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
              child: const Text('Rental', style: TextStyle(color: Colors.white)),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
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
                    MaterialPageRoute(builder: (context) => const RequestForRentScreen()),
                  ),
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
                    MaterialPageRoute(builder: (context) => Homepage()),
                  ),
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
                  child: const Text('Delivery', style: TextStyle(color: Colors.amber)),
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
      onTap: _handleNavigation,
      activeColor: Colors.amber,
      inactiveColor: Colors.grey,
      backgroundColor: const Color.fromARGB(255, 148, 93, 93),
      iconSize: 30.0,
    );
  }

  void _handleNavigation(int index) {
    final routes = [
      MaterialPageRoute(builder: (_) => const HomeMap()),
      MaterialPageRoute(builder: (_) => const Homepage()),
      MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
      MaterialPageRoute(builder: (_) => const HomeNotifications()),
      MaterialPageRoute(builder: (_) => const HomeSettings()),
    ];

    if (index >= 0 && index < routes.length) {
      setState(() => _selectedIndex = index);
      Navigator.push(context, routes[index]);
    }
  }


  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _webSocket?.sink.close();
    mapboxMap?.dispose();
    super.dispose();
  }
}
